//
//  AlertListViewController.swift
//  13-DrinkWater
//
//  Created by 정현준 on 2022/01/31.
//

import UIKit
import UserNotifications

class AlertListViewController: UITableViewController {
    var alerts: [Alert] = []
    let userNotificationCenter = UNUserNotificationCenter.current()

    override func viewDidLoad() {
        super.viewDidLoad()

        let nibName = UINib(nibName: "AlertListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "AlertListCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        alerts = alertList()
    }

    @IBAction func addAlertButtonAction(_ sender: UIBarButtonItem) {
        guard let addAlertViewController = storyboard?.instantiateViewController(identifier: "AddAlertViewController") as? AddAlertViewController else { return }

        addAlertViewController.pickedDate = {[weak self] date in
            guard let self = self else {return}

            // 데이터 업데이트
            var alertList = self.alertList()
            let newAlert = Alert(date: date, isOn: true)
            alertList.append(newAlert)
            alertList.sort{ $0.date < $1.date }

            self.alerts = alertList

            // 업데이트 된 데이터 UserDefaults 저장소에 저장
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts")
            self.userNotificationCenter.addNotificationRequest(by: newAlert) // 새로 만들어진 alert가 notification center에도 저장

            self.tableView.reloadData()
        }

        self.present(addAlertViewController, animated: true, completion: nil)

    }

    func alertList() -> [Alert] {
        guard let data = UserDefaults.standard.value(forKey: "alerts") as? Data,
              let alerts = try? PropertyListDecoder().decode([Alert].self, from: data) else { return [] }
        return alerts
    }
}

// UITableView: Datasource, Delegate
extension AlertListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alerts.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "🚰 물 마실 시간"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertListCell", for:indexPath) as? AlertListCell else { return UITableViewCell () }

        let alert = alerts[indexPath.row]
        cell.alertSwitch.isOn = alert.isOn
        cell.timeLabel.text = alert.time
        cell.meridiemLabel.text = alert.meridiem

        cell.alertSwitch.tag = indexPath.row // switch 버튼 구현 방법(1): 스위치의 tag값을 indexPath.row로 지정

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return 80
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            // Notification 삭제 구현
            self.alerts.remove(at: indexPath.row)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.alerts), forKey: "alerts")
            userNotificationCenter.removePendingNotificationRequests(withIdentifiers: [alerts[indexPath.row].id])

            self.tableView.reloadData()
            
        default:
            break
        }
    }
}
