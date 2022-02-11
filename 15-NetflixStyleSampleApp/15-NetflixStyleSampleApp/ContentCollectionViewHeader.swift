//
//  ContentCollectionViewHeader.swift
//  15-NetflixStyleSampleApp
//
//  Created by 정현준 on 2022/02/04.
//
import UIKit

// 반드시 리유저블 뷰 형태여야 함!!!
class ContentCollectionViewHeader: UICollectionReusableView {
    let sectionNameLabel = UILabel()

    override func layoutSubviews() {
        super.layoutSubviews()

        sectionNameLabel.font = .systemFont(ofSize: 17, weight: .bold)
        sectionNameLabel.textColor = .white
        sectionNameLabel.sizeToFit()

        addSubview(sectionNameLabel)

        sectionNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.top.bottom.leading.equalToSuperview().offset(10)
        }
    }
}
