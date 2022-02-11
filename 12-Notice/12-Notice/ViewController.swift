//
//  ViewController.swift
//  12-Notice
//
//  Created by 정현준 on 2022/01/30.
//

import UIKit
import FirebaseRemoteConfig
import FirebaseAnalytics

class ViewController: UIViewController {

    var remoteConfig: RemoteConfig?

    override func viewDidLoad() {
        super.viewDidLoad()
        remoteConfig = RemoteConfig.remoteConfig()

        let setting = RemoteConfigSettings()
        setting.minimumFetchInterval = 0 // 테스트를 위해 새로운 값 패치하는 간격을 최소화 시켜 데이터를 자주 가져오도록 함

        remoteConfig?.configSettings = setting
        remoteConfig?.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNotice()
    }
}

// Remote Configure
extension ViewController {
    func getNotice() {
        guard let remoteConfig = remoteConfig else { return }
        remoteConfig.fetch(completionHandler: { [weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("ERROR: Config not fetched")
            }

            // 만약, isNoticeHidden이 아닌경우 (보여질 예정인 경우) noticeVC 실행
            guard let self = self else { return }
            if !self.isNoticeHidden(remoteConfig) {
                let noticeVC = NoticeViewController(nibName: "NoticeViewController", bundle: nil)
                noticeVC.modalPresentationStyle = .custom
                noticeVC.modalTransitionStyle = .crossDissolve

                // .replacingOccurrences(of: "\\n", with: "\n"): 여러줄 입력하는 경우 swift는 인식 못하기 때문에 인식하도록 대체
                let title = (remoteConfig["title"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let detail = (remoteConfig["detail"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")
                let date = (remoteConfig["date"].stringValue ?? "").replacingOccurrences(of: "\\n", with: "\n")

                noticeVC.noticeContents = (title: title, detail: detail, date: date)
                self.present(noticeVC, animated: true, completion: nil)
            } else {
                self.showEventAlert()
            }
        })
    }

    func isNoticeHidden(_ remoteConfig: RemoteConfig) -> Bool {
        return remoteConfig["isHidden"].boolValue
    }
}

// A/B Testing
extension ViewController {
    func showEventAlert() {
        guard let remoteConfig = remoteConfig else { return }
        remoteConfig.fetch { [weak self] status, _ in
            if status == .success {
                remoteConfig.activate(completion: nil)
            } else {
                print("CONFIG NOT FETCHED")
            }

            let message = remoteConfig["message"].stringValue ?? "서비스 이용에 참고 부탁드립니다."

            let confirmAction = UIAlertAction(title: "확인하기", style: .default) { _ in
                // Google Analytics
                Analytics.logEvent("promotion_alert", parameters: nil)
            }

            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            let alertController = UIAlertController(title: "깜짝이벤트", message: message, preferredStyle: .alert)

            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)

            self?.present(alertController, animated: true, completion: nil)
        }
    }
}
