//
//  RoundButton.swift
//  04-Calculator
//
//  Created by 정현준 on 2022/01/10.
//

import UIKit

// 스토리보드상에 실시간으로 확인 할 수 있도록 @IBDesignable annotation 선언
@IBDesignable
class RoundButton: UIButton {
    // @IBInspectable annotation을 선언하여 스토리보드에서도 isRound 값을 변경시킬 수 있도록 설정한다.
    @IBInspectable var isRound: Bool = false {
        // isRound = trued인 경우에 (버튼의 높이 / 2) 만큼으로 곡률을 설정한다
        didSet {
            if isRound {
                self.layer.cornerRadius = self.frame.height / 2
            }
        }
    }
}
