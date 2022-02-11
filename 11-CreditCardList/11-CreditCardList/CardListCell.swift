//
//  CardListCell.swift
//  11-CreditCardList
//
//  Created by 정현준 on 2022/01/25.
//

import UIKit

class CardListCell: UITableViewCell {
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var promotionLabel: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)


    }
    
}
