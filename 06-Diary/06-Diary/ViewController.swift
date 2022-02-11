//
//  ViewController.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    // Diary 구조체 타입의 바탕으로 배열 생성
    private var diaryList = [Diary]() {
        didSet {
            self.saveDiaryList() // 다이어리 리스트 생성, 추가시 저장소에 저장시켜 재실행해도 데이터 유지시킴
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView() // 추가되는 일기 CollectionView에 구현
        self.loadDiaryList() // 기존에 저장된 다이어리 리스트 불러오기

        // DiaryDetailView에서 수정이 일어났을 때 해당 내용 반영
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name(rawValue: "editDiary"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )
    }

    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == diary.uuidString }) else { return }
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        self.collectionView.reloadData()
    }

    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }

        self.diaryList[index].isStar = isStar
    }

    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else {return}
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList.remove(at: index) // 데이터상에서 삭제
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)]) // 콜렉션뷰 상에서 삭제
    }


    // MARK: 추가된 일기를 CollectionView에 구현시키기
    private func configureCollectionView() {
        // UICollectionView의 레이아웃을 잡을 땐 UICollectionViewFlowLayout을 사용함
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) // 콜렉션 뷰 컨텐츠의 상,하,좌,우 간격 설정

        // UICollectionViewDataSource와 UICollectionViewDelegate 프로토콜 선언을 바탕으로 delegate 및 dataSource 객체를 self로 설정
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    // 일기 작성 화면으로의 이동은 세그웨이로 이동하기 때문에 prepare 메서드 오버라이딩
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // writeDiaryViewController 객체를 생성 -> extension으로 WriteDiaryViewDelegate 생성 및 함수 작성 -> delegate 선언
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            writeDiaryViewController.delegate = self
        }
    }

    // date 타입을 문자열로 변경시키는 함수 작성
    private func dateToString(date: Date)  -> String {
        let formatter = DateFormatter() // DateFormmater 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)" // dateFormat 프로퍼티에 형식 지정
        formatter.locale = Locale(identifier: "ko_KR") // Locale 객체를 생성해 한국어로 설정

        return formatter.string(from: date) // 지정된 형식으로 추출된 Date 타입 데이터를 String으로 변환
    }

    // MARK: UserDefault를 이용해서 앱 재실행해도 데이터 유지 시키기
    // diaryList 저장소에 저장
    private func saveDiaryList() {
        let data = self.diaryList.map {
            [
                "uuidString": $0.uuidString,
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        let userDefaults = UserDefaults.standard // 싱글톤 방식으로 UserDefaults에 접근
        userDefaults.set(data, forKey: "diaryList") // data를 "diaryList"라는 key 값으로 저장
    }

    // 저장된 diaryList 불러오기
    private func loadDiaryList() {
        // 싱글톤 방식으로 UserDefaults 접근
        let userDefaults = UserDefaults.standard

        // 저장했을 때 설정한 key값을 입력해 불러옴. 단, Any 타입으로 받아오기 때문에 Dictionary로 타입 캐스팅 및 옵셔널 바인딩 설정
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String:Any]] else { return }

        // 불러온 데이터를 diaryList에 맞게 맵핑
        self.diaryList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else {return nil}
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }

        // 최신순으로 다이어리 정렬 (내림차순 정렬)
        self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
    }
}

// MARK: 선언 프로토콜 모음
extension ViewController: UICollectionViewDataSource{ // CollectionView에 일기장 목록 표시할 데이터 준비
    // numberOfItemsInSection: 지정된 섹션에 표시할 셀의 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }

    // cellForItemAt: 지정된 위치에 어떤 셀을 표시할지
    // DiaryCell로 타입캐스팅한 cell을 생성함
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date) // 앞에서 선언한 dateToString을 이용해 Date -> String 변환시켜 지정
        return cell
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout { // CollectionView에 레이아웃 구성하기
    // Cell 사이즈 지정 (CGSize 타입)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200) // 너비: (스크린 너비 / 2) - (좌, 우 간격), 높이: 200
    }
}

extension ViewController: WriteDiaryViewDelegate {
    // ViewController의 diaryList에 WriteDiaryViewDelegate에서 저장해둔 diary 추가하도록 함수 작성
    func didSelectRegister(diary: Diary) {
        // diaryList에 추가 후, 최신순으로 정렬 (날짜 내림차순)
        self.diaryList.append(diary)
        self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
        self.collectionView.reloadData() // 일기를 추가할 때 마다 collectionView를 reload
    }
}

// MARK: DiaryDetailViewController로 화면 전환 구현
extension ViewController: UICollectionViewDelegate {
    // didSelectItemAt -> 특정 셀이 선택되었을 때 작업 ... DiaryDetailViewController로 넘기기
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // DiaryDetailViewController 및 diary 데이터 불러오기
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]

        // DiaryDetailViewController의 요소에 diary 데이터의 프로퍼티 매칭
        vc.diary = diary
        vc.indexPath = indexPath

        self.navigationController?.pushViewController(vc, animated: true) // 다음 화면으로 넘어가는 pushViewController 메서드 사용
    }
}
