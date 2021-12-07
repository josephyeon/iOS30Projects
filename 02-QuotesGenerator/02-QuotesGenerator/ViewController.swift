//
//  ViewController.swift
//  02-QuotesGenerator
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!

    let quotes: [Quote] = [
        Quote(contents: "죽음을 두려워하는 나머지 삶을 시작조차 못하는 사람이 많다.", name: "벤다이크"),
        Quote(contents: "아프면 자기 손해이고, 세상엔 나 혼자밖에 없으며, 울어도 힘든 일은 해결되지 않는다.", name: "보아"),
        Quote(contents: "미디어에 교태를 팔아 인기를 회복하는 것은 절대 싫다. 1부터 치고 올라갈 것이다.", name: "아무로 나미에"),
        Quote(contents: "나는 나 자신을 빼 놓고는 모두 안다", name: "비용"),
        Quote(contents: "분노는 바보들의 가슴속에서만 살아간다", name: "아인슈타인"),
        Quote(contents: "몇 번이라도 좋다! 이 끔찍한 생이여.. 다시!", name: "니체"),
        Quote(contents: "편견이란 실효성이 없는 의견이다.", name: "암브로스 빌")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapQuoteGengeratorButton(_ sender: UIButton) {
        // 랜덤 난수 생성
        let random = arc4random_uniform(UInt32(quotes.count)) // 0 ~ (quotes.count - 1)사이의 난수 생성
        let idx = Int(random) // 생성한 난수는 index에 접근할 수 있도록 Int로 변환
        let quote = quotes[idx] // 난수를 이용해 뽑아낸 quote 불러오기

        // View에 나타낼 데이터 지정
        self.quoteLabel.text = quote.contents
        self.nameLabel.text = quote.name
    }

}

