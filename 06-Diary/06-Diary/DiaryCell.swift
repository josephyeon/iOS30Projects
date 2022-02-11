//
//  DiaryCell.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/18.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    // MARK: 셀 테두리 구현 (코드로 작성)
    // required init: UIView에서 객체를 생성할때 사용
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0 
        self.contentView.layer.borderColor = UIColor.systemGray2.cgColor
    }

}
