//
//  StarViewController.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/18.
//

import UIKit

class StarViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    private var diaryList = [Diary]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
        self.loadStarDiaryList()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
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

    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    // userDefaults를 이용해 isStar = true 인 일기 추가시켜 나타내기
    private func loadStarDiaryList() {
        // UserDefaults 싱글톤을 생성해 저장된 object 불러오기
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] else { return }
        self.diaryList = data.compactMap{
            guard let uuidString = $0["uuidString"] as? String else { return nil }
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }.filter({
            $0.isStar == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
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
        guard let diary = starDiary["diary"] as? Diary else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }


        if isStar {
            self.diaryList.append(diary)
            self.diaryList = self.diaryList.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            self.collectionView.reloadData()
        } else {
            guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.diaryList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }

    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else {return}
        guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
    }


    private func dateToString(date: Date)  -> String {
        let formatter = DateFormatter() // DateFormmater 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)" // dateFormat 프로퍼티에 형식 지정
        formatter.locale = Locale(identifier: "ko_KR") // Locale 객체를 생성해 한국어로 설정

        return formatter.string(from: date) // 지정된 형식으로 추출된 Date 타입 데이터를 String으로 변환
    }
}

extension StarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath) as? StarCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row]
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = self.dateToString(date: diary.date)
        return cell
    }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

extension StarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        vc.diary = diary
        vc.indexPath = indexPath
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
