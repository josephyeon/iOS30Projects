//
//  DiaryDetailViewController.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/18.
//

import UIKit

// MARK: 일기장 삭제 기능 구현

class DiaryDetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    var starButton: UIBarButtonItem?

    // 일기장 리스트에서 전달 받을 프로퍼티 선언
    var diary: Diary?
    var indexPath: IndexPath?


    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
    }

    // 프로퍼티를 통해 전달받은 다이어리 객체를 여기 View에서 초기화
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)

        // 즐겨찾기 버튼 생성 및 추가 여부 반영
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tapStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }

    private func dateToString(date: Date)  -> String {
        let formatter = DateFormatter() // DateFormmater 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)" // dateFormat 프로퍼티에 형식 지정
        formatter.locale = Locale(identifier: "ko_KR") // Locale 객체를 생성해 한국어로 설정
        return formatter.string(from: date) // 지정된 형식으로 추출된 Date 타입 데이터를 String으로 변환
    }

    @IBAction func tapEditButton(_ sender: UIButton) {
        // MARK: 수정 기능 구현
        // 수정 버튼 클릭 -> WriteDiaryView로 전환시킨다.
        guard let vc = self.storyboard?.instantiateViewController(identifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }

        // 단, 작성한 내용이 WriteDiaryView에 그대로 떠야 한다
        // WriteDiaryViewController에서 작성한 diaryEditorMode의 case edit(IndexPath, Diary)에 알맞게 각 프로퍼티 생성 후 edit 선언
        guard let indexPath = self.indexPath else {return}
        guard let diary = self.diary else {return}
        vc.diaryEditorMode = .edit(indexPath, diary) // edit 모드 선언

        // WriteDiaryViewController에서 Post 메서드를 이용해 보낸 수정 데이터를 Obseving 하도록 구현
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)), // observing한 뒤에 뭘 할건지? -> 여기에 업데이트 시킬 것!
            name: NSNotification.Name("editDiary"),
            object: nil
        )

        // 화면 전환
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // observe된 Notification으로 수정된 다이어리 업데이트 시키기
    @objc func editDiaryNotification(_ notifiacation: Notification) {
        guard let diary = notifiacation.object as? Diary else { return }
        self.diary = diary
        self.configureView()
    }

    @objc func starDiaryNotification(_ notifictation: Notification) {
        guard let starDiary = notifictation.object as? [String: Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.configureView()
        }
    }

    @objc func tapStarButton() {
        guard let isStar = self.diary?.isStar else { return }
        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object:[
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                "uuidString" : self.diary?.uuidString,
            ],
            userInfo: nil)
    }

    @IBAction func tapDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.diary?.uuidString else { return } // 옵셔널 바인딩으로 indexPath 불러오기
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
            )
        self.navigationController?.popViewController(animated: true) // 삭제 처리 후 이전화면(목록 화면)으로 돌아가기
    }

    // 수정된 일기로 업데이트 후 인스턴스가 소멸될 때 (deinit) -> 해당 인스턴스에 추가된 observer가 모두 제거되게 만들어준다.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
