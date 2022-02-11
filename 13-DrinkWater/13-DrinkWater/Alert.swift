//
//  Alert.swift
//  13-DrinkWater
//
//  Created by 정현준 on 2022/01/31.
//

import Foundation

struct Alert: Codable {
    var id: String = UUID().uuidString
    let date: Date
    var isOn: Bool

    var time: String { // Date -> String
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm"
        return timeFormatter.string(from: date)
    }

    var meridiem: String {
        let meridiemFormatter = DateFormatter()
        meridiemFormatter.dateFormat = "a"
        meridiemFormatter.locale = Locale(identifier: "ko")
        return meridiemFormatter.string(from: date)
    }
}
