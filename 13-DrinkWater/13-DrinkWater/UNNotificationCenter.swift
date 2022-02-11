//
//  UNNotificationCenter.swift
//  13-DrinkWater
//
//  Created by 정현준 on 2022/01/31.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    func addNotificationRequest(by alert: Alert) {
        let content = UNMutableNotificationContent()
        content.title = "물 마실 시간이에요!"
        content.body = "세계보건기구(WHO)가 권장하는 하루 물 섭취량은 1.5~2리터 입니다."
        content.sound = .default
        content.badge = 1 // SceneDelegate.swift의 sceneDidBecomeActive를 활성화 시켜주어야 배지 생성, 소멸이 가능!

        // 알림 트리거 설정하기
        let component = Calendar.current.dateComponents([.hour, .minute], from: alert.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: component, repeats: alert.isOn)

        // 리퀘스트 설정하기
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: trigger)

        self.add(request, withCompletionHandler: nil)
    }
}
