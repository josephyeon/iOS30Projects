//
//  CodePresentViewController.swift
//  ScreenTransitionExample
//
//  Created by 정현준 on 2021/12/10.
//

import UIKit

protocol SendDataDelegate: AnyObject{
    func sendData(name: String)
}

class CodePresentViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    var name: String?
    weak var delegate: SendDataDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let name = name {
            self.nameLabel.text = name
        }
    }
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.delegate?.sendData(name: "이전 화면으로 데이터 전송 성공")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
