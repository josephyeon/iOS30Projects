//
//  CardDetailViewController.swift
//  11-CreditCardList
//
//  Created by 정현준 on 2022/01/25.
//

import UIKit
import Lottie

class CardDetailViewController: UIViewController {
    var promotionDetail: PromotionDetail?

    @IBOutlet weak var lottieView: AnimationView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var benefitConditionLabel: UILabel!
    @IBOutlet weak var benefitDetailLabel: UILabel!
    @IBOutlet weak var benefitDateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 오픈소스 Lottie를 이용하여 StackView상에 삽입된 View에 움짤이 재생되도록 구현
        let animationView = AnimationView(name: "92478-money")
        lottieView.contentMode = .scaleAspectFit
        lottieView.addSubview(animationView)
        animationView.frame = lottieView.bounds
        animationView.loopMode = .loop
        animationView.play()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let detail = promotionDetail else { return }

        titleLabel.text = """
            \(detail.companyName)카드 쓰면
            \(detail.amount)만원 드려요
            """
        periodLabel.text = promotionDetail?.period
        conditionLabel.text = promotionDetail?.condition
        benefitConditionLabel.text = promotionDetail?.benefitCondition
        benefitDetailLabel.text = promotionDetail?.benefitDetail
        benefitDateLabel.text = promotionDetail?.benefitDate
    }
}
