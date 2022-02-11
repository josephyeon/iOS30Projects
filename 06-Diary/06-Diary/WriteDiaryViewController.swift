//
//  WriteDiaryViewController.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/18.
//

import UIKit

// 새 일기 작성, 일기 수정 모드를 열거형으로 생성
enum DiaryEditorMode {
    case new
    case edit(IndexPath, Diary)
}

// 일기 리스트가 기록된 Diary 객체를 전달하기 위한 Delegate 프로토콜 정의
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary)
}

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var confirmButton: UIBarButtonItem!


    // 날짜 입력시 키보드가 아닌, datePicker가 나타나도록 설정 (1) - UIDatePicker 객체 선언
    private let datePicker = UIDatePicker()
    private var diaryDate: Date? // datePicker에서 선택된 데이터를 저장하는 프로퍼티

    weak var delegate: WriteDiaryViewDelegate? // Diary 객체 전달을 위한 Delegate 프로토콜 선언

    var diaryEditorMode: DiaryEditorMode = .new // 앞에서 작성한 열거형 DiaryEditorMode을 바탕으로 새 다이어리 작성을 기본 모드로 설정


    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.configureInputField()
        self.configureEditMode()
        self.confirmButton.isEnabled = false // 등록버튼 우선 비활성화 설정 (초기엔 아무것도 작성 안되어있으니까)
    }

    // 제목, 내용, 날짜가 모두 작성되었을 때만 등록 버튼이 활성화되도록 설정
        // 하단 extension에서 구현
    private func configureInputField() {
        self.contentsTextView.delegate = self
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }

    // 내용 작성 TextView에 구분선이 나타나도록 private 함수로 작성
    private func configureContentsTextView() {
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        // 레이아웃의 색상은 UIColor가 아닌, cgColor로 설정해야 한다.
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5
        self.contentsTextView.layer.cornerRadius = 5.0
    }

    // 날짜 입력시 키보드가 아닌, datePicker가 나타나도록 설정 (2) - datePicker를 어떻게 구성할지 private 함수로 작성
    private func configureDatePicker() {
        // 날짜만 입력하는 모드로 설정
        self.datePicker.datePickerMode = .date

        // 휠처럼 위아래로 돌려서 맞추는 인터페이스
        self.datePicker.preferredDatePickerStyle = .wheels

        // UIController 객체가 이벤트에 어떻게 응답하는지 설정
            // 어디서 처리할건가? (_ target) : 해당 뷰 컨트롤러
            // 어떤 콜백함수 쓸건가? (action): dateTextField에 나타내는 함수
            // 어떤 이벤트가 일어났을 때 쓸건가?: datePikcer값이 변경될 때
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)

        // datePicker가 한글 모드로 나타나게 설정
        self.datePicker.locale = Locale(identifier: "ko-KR")

        // dateTextField를 클릭했을 때 키보드가 아닌, datePicker가 표시되도록 설정
        self.dateTextField.inputView = self.datePicker
    }

    // MARK: DiaryDetailView에서 수정 모드로 넘어온 데이터들 그대로 나타내기
    private func configureEditMode() {
        switch self.diaryEditorMode{
        case let.edit(_, diary):
            self.titleTextField.text = diary.title
            self.contentsTextView.text = diary.contents
            self.dateTextField.text = self.dateToString(date: diary.date)
            self.diaryDate = diary.date
            self.confirmButton.title = "수정"

        default:
            break
        }
    }

    private func dateToString(date: Date)  -> String {
        let formatter = DateFormatter() // DateFormmater 객체 생성
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)" // dateFormat 프로퍼티에 형식 지정
        formatter.locale = Locale(identifier: "ko_KR") // Locale 객체를 생성해 한국어로 설정

        return formatter.string(from: date) // 지정된 형식으로 추출된 Date 타입 데이터를 String으로 변환
    }

    // 등록 버튼을 누르면 Diary 객체에 맞춰 저장시키고, delegate 프로토콜을 준수하여 데이터 전달
    @IBAction func tapConfirmButton(_ sender: UIBarButtonItem) {
        // Diary 객체에 맞춰 변형
        guard let title = self.titleTextField.text else { return }
        guard let contents = self.contentsTextView.text else { return }
        guard let date = self.diaryDate else { return }

        // 앞에서 선언한 delegate 프로토콜 준수하여 데이터 전달
        // 수정모드의 경우, Notification Center의 POST 메서드를 이용해 수정한 내용을 저장(Observing)시키도록 구현
        switch self.diaryEditorMode {
        case .new:
            let diary = Diary(
                uuidString: UUID().uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: false
            )
            self.delegate?.didSelectRegister(diary: diary)

        case let .edit(indexPath, diary):
            let diary = Diary(
                uuidString: diary.uuidString,
                title: title,
                contents: contents,
                date: date,
                isStar: diary.isStar
            )

            NotificationCenter.default.post(
                name: NSNotification.Name("editDiary"),
                object: diary,
                userInfo: nil
            )
        }
        self.navigationController?.popViewController(animated: true) // 데이터 전달이 완료되면 popViewController 메서드를 이용해 일기장 목록으로 되돌아가기
    }

    // 날짜 입력시 키보드가 아닌, datePicker가 나타나도록 설정 (3) - configureDatePicker 함수 중 addTarget의 action에 쓸 함수 구현
        // 선택한 datePicker 타입의 데이터를 String으로 변환시켜 dateTextField에 나타냄
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        // Date 타입 <=> String으로 변환시켜주는 DateFrommatter() 객체 선언
        let formmatter = DateFormatter()
        formmatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)" // 날짜 나타낼 형태 지정, EEEEE: 요일을 한 글자로만 표현하도록 설정
        formmatter.locale = Locale(identifier: "ko_KR") // 한국어로 표현

        // datePicker에서 선택한 데이터 diaryDate로 저장
        self.diaryDate = datePicker.date

        // dateTextField에 선택한 데이터가 표시되도록 설정
        self.dateTextField.text = formmatter.string(from: datePicker.date)

        // dateTextField는 텍스트를 키보드로 입력받는 형태가 아님
        // sendActions를 이용해 날짜가 변경됨을 감지하도록 하여 dateTextFieldDidChange을 호출
        self.dateTextField.sendActions(for: .editingChanged)
    }

    // 제목, 날짜 텍스트 필드에 입력될 때 마다 호출되는 메서드 각각 정의
    @objc private func titleTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField() // 제목이 입력될 때 마다 등록버튼 활성화 여부 판단
    }

    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField() // 제목이 입력될 때 마다 등록버튼 활성화 여부 판단
    }


    // 키보드, datePicker 나타난 상태에서 빈 화면을 눌렀을 때 닫히도록 구현
        // touchesBegan 함수를 오버라이딩
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 빈 화면 터치시 편집 중단시키면 됨
    }

    // 내용이 입력 될 때 마다 등록버튼 활성화 여부를 판단하는 메서드 구현
    private func validateInputField() {
        // 모든 input 필드가 비어있지 않을 때 등록 버튼 isEnabled = true 처리
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) && !(self.dateTextField.text?.isEmpty ?? true) && !(self.contentsTextView.text.isEmpty ?? true)
    }
}

extension WriteDiaryViewController: UITextViewDelegate {

    // text를 입력할때 마다 validateInputField()를 실행시켜 등록버튼을 활성화시킬지 정한다.
    func textViewDidChange(_ textView: UITextView) {
        self.validateInputField()
    }
}
