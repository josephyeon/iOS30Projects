//
//  CreditCard.swift
//  11-CreditCardList
//
//  Created by 정현준 on 2022/01/25.
//

import Foundation

struct CreditCard: Codable {
    let id: Int
    let rank: Int
    let name: String
    let cardImageURL: String
    let promotionDetail: PromotionDetail
    let isSelected: Bool? // 추후에 사용자가 카드를 선택했을 때를 대비해 추가적으로 생성
}

struct PromotionDetail: Codable {
    let companyName: String
    let period: String
    let amount: Int
    let condition: String
    let benefitCondition: String
    let benefitDetail: String
    let benefitDate: String
}
