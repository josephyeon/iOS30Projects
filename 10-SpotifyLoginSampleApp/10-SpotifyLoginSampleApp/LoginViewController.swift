import UIKit
import GoogleSignIn
import Firebase
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailLoginButton: UIButton!
    @IBOutlet weak var googleLoginButton: GIDSignInButton! // UIBUtton을 상속하면서 구글 로그인 구현
    @IBOutlet weak var appleLoginButton: UIButton!

    private var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // 세 버튼에 동일한 UI 적용시키기
        [emailLoginButton, googleLoginButton,appleLoginButton].forEach { $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.white.cgColor
            $0?.layer.cornerRadius = 30
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Navigation Bar 숨기기
        navigationController?.navigationBar.isHidden = true

    }

    @IBAction func googleLoginButtonTapped(_ sender: UIButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            if let error = error {
                debugPrint("error: \(error)")
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else { return }

            // authentication과 accessToken으로 credential 부여
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)

            // 토큰을 이용해 Firebase에 등록
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let authError = error as NSError
                    debugPrint("authError: \(authError)")
                } else {
                    self?.showMainViewController()
                }
            }
        }
    }

    // 주의! AppleSignIn은 Simulator에서 제대로 작동하지 않는다! -> 실제 기기로 확인 가능함!
    @IBAction func appleLoginButtonTapped(_ sender: UIButton) {
        startSignInWithAppleFlow()
    }

    private func showMainViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = storyboard.instantiateViewController(identifier: "MainViewController")
        mainVC.modalPresentationStyle = .fullScreen
        UIApplication.shared.windows.first?.rootViewController?.show(mainVC, sender: nil)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            /**
             # Nonce란?
             - 암호화된 임의의 난수
             - 단 한번만 사용할 수 있는 값
             - 주로 암호화 통신에 사용
             - 동일 요청을 짧은 시간에 여러번 보내는 릴레이 공격 방지
             - 정보 타루치 없이 안전하게 인증 정보 전달을 위한 안전장치 */

            guard let nonce = currentNonce else { // App -> Apple 또는 Firebase 전달 과정에서 릴레이 공격, 정보 탈취 없이 안전하게 인증
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }

            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print ("Error Apple sign in: %@", error)
                    return
                }
                // User is signed in to Firebase with Apple.
                // ...
                ///Main 화면으로 보내기
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let mainViewController = storyboard.instantiateViewController(identifier: "MainViewController")
                mainViewController.modalPresentationStyle = .fullScreen
                self.navigationController?.show(mainViewController, sender: nil)
            }
        }
    }
}

// Apple Sign in
// 어려운 내용이기 때문에 모두 다 이해할 필요 없음 (Firebase에서 기본 제공하는 코드임!)
extension LoginViewController {
    // 이 함수는 중요! - nonce가 포함되어 릴레이 공격을 방지하고, firebase에서도 무결성 확인이 가능함!
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}

extension LoginViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
