//
//  EnterEmailViewController.swift
//  10-SpotifyLoginSampleApp
//
//  Created by 정현준 on 2022/01/24.
//

import UIKit
import FirebaseAuth

class EnterEmailViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 네비게이션 바 보이도록 설정
        navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        nextButton.layer.cornerRadius = 30

        nextButton.isEnabled = false // 이메일, 비밀번호 미입력시 다음 버튼 활성화 막아둠

        emailTextField.delegate = self
        passwordTextField.delegate = self

        emailTextField.becomeFirstResponder() // 화면을 켰을 때 커서가 이메일 텍스트 필드에 바로 위치
    }

    // Firebase 이메일/비밀번호 인증
    @IBAction func nextbuttonTapped(_ sender: UIButton) {
        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""

        // 신규 사용자 생성
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            // 동일 계정 중복 입력 방지
            if let error = error {
                let code = (error as NSError).code
                switch code {
                case 17007: // 이미 가입한 계정
                    self.loginUser(withEmail: email, password: password)
                default: // 그 외 - 잘못 입력한 계정
                    self.errorMessageLabel.text
                    error.localizedDescription
                }
            } else {
                self.showMainViewController()
            }
        }
    }

    // MainView로 넘어가기 (함수로 따로 만들어냄)
    private func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = storyboard.instantiateViewController(identifier: "MainViewController")

        mainVC.modalPresentationStyle = .fullScreen
        navigationController?.show(mainVC, sender: nil)
    }

    // 기존 계정이 존재하는 경우 로그인을 제공해주는 firebase 클로저 생성
    private func loginUser(withEmail email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            guard let self = self else { return }

            // 로그인 과정에서도 이메일, 비밀번호 불일치 등의 오류가 발생하는 경우도 있으니 에러처리 설정
            if let error = error {
                self.errorMessageLabel.text = error.localizedDescription
            } else {
                self.showMainViewController()
            }
        }
    }
}

extension EnterEmailViewController: UITextFieldDelegate {
    // 이메일, 비밀번호 입력 마치고 키보드의 return 버튼을 누르면 키보드 내려가게 설정
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    // 텍스트 값이 모두 있을 때 다음 버튼 활성
    func textFieldDidEndEditing(_ textField: UITextField) {
        let isEmailEmpty = emailTextField.text == ""
        let isPasswordEmpty = passwordTextField.text == ""
        nextButton.isEnabled = !isEmailEmpty && !isPasswordEmpty
    }
}
