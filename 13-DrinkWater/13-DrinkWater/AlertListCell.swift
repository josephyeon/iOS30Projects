//
//  AlertListCell.swift
//  13-DrinkWater
//
//  Created by 정현준 on 2022/01/31.
//

import UIKit
import UserNotifications

class AlertListCell: UITableViewCell {
    let userNotificationCenter = UNUserNotificationCenter.current()

    @IBOutlet weak var meridiemLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var alertSwitch: UISwitch!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func alertSwitchValueChanged(_ sender: UISwitch) {
        // 스위치 구현 (2): AlertListViewController에서 지정된 indexPath.row 값을 이용

        // "alert"이라는 UserDefaults 저장소의 값을 가지고 나옴
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              var alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return }

        // alerts 배열에 있는 값 중 해당되는 데이터의 isOn 값을 sender의 isOn 값으로 변경
        alerts[sender.tag].isOn = sender.isOn

        // 변경된 값을 다시 alerts 프로퍼티 리스트에 set -> 항상 최신 상태를 유지!
        UserDefaults.standard.set(try? PropertyListEncoder().encode(alerts), forKey: "alerts")

        // 스위치 on 시킨 경우 -> 해당 시간에 울리도록 Notification center에 추가
        if sender.isOn {
            print("sender.isOn: \(sender.isOn)")
            userNotificationCenter.addNotificationRequest(by: alerts[sender.tag])
        } else { // 스위치 off 시킨 경우 -> Notification center에서 제거
            print("sender.isOn: \(sender.isOn)")
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[sender.tag].id])
        }
    }

    
}
