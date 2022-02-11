//
//  MainViewController.swift
//  10-SpotifyLoginSampleApp
//
//  Created by 정현준 on 2022/01/24.
//

import UIKit
import FirebaseAuth

class MainViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var resetPassword: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // pop 제스쳐를 막을 수 있도록 구현
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 네비게이션 바는 숨기기
        navigationController?.navigationBar.isHidden = true

        let email = Auth.auth().currentUser?.email ?? "고객"
        welcomeLabel.text = """
        환영합니다.
        \(email)님
        """

        // 이메일/비밀번호 방식으로 로그인하지 않은 경우 버튼 숨기기
        let isEmailSginIn = Auth.auth().currentUser?.providerData[0].providerID == "password"
        resetPassword.isHidden = !isEmailSginIn
    }

    // 애플 로그인의 경우, 사용자 이메일 가리기 기능이 존재! => 그래서 사용자의 닉네임이 나타내도록 설정
    // Firebase 인증에서 사용자 프로필 업데이트 메소드를 이용해 구현
    @IBAction func profileUpdateButtonTapped(_ sender: UIButton) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "하이언"
        changeRequest?.commitChanges { _ in
            let displayName = Auth.auth().currentUser?.displayName ?? Auth.auth().currentUser?.email ?? "고객"

            self.welcomeLabel.text = """
            환영합니다.
            \(displayName)님
            """
        }
    }

    // 각 인증업체별 로그아웃이 아닌, Firebase 인증 값에 대한 로그아웃을 진행
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()

        do { // 로그아웃 시도시 성공하면 처음 화면으로 돌아가게 설정
            try firebaseAuth.signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("ERROR: signout \(signOutError.localizedDescription)")
        }
    }

    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        let email = Auth.auth().currentUser?.email ?? ""
        Auth.auth().sendPasswordReset(withEmail: email, completion: nil)
    }
}
