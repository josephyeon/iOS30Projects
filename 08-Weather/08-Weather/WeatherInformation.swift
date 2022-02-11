//
//  WeatherInformation.swift
//  08-Weather
//
//  Created by 정현준 on 2022/01/22.
//

// MARK: 날씨 정보 저장을 위한 구조체 생성
import Foundation

// Codable 프로토콜 채택: 자신을 변환하거나 외부 표현(json형태 ...)으로 변환하게끔 설정 (decodable, encodable 프로토콜 모두 가능)
    // json <=> WeatherInformation 서로 변환 가능
struct WeatherInformation: Codable {
    let weather: [Weather]
    let temp: Temp
    let name: String

    // 그런데, temp 프로퍼티는 json 파일 구조상 "main"키에 해당되어 맵핑이 필요함!
    enum CodingKeys: String, CodingKey {
        case weather
        case temp = "main"
        case name
    }
}

struct Weather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Temp: Codable {
    let temp: Double
    let feelsLike: Double
    let minTemp: Double // open weather API에서는 temp_min, temp_max로 되어있어 불일치 => 맵핑으로 해결!
    let maxTemp: Double

    // MARK: json 키와 프로퍼티 이름 서로 맵핑 시키기
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case minTemp = "temp_min"
        case maxTemp = "temp_max"
    }
}


