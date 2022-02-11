//
//  SeguePushViewController.swift
//  ScreenTransitionExample
//
//  Created by 정현준 on 2021/12/10.
//

import UIKit

class SeguePushViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        print("SeguePushViewController 뷰가 로드되었다. (ViewDidLoad)")
        if let name = name {
            self.nameLabel.text = name
            self.nameLabel.sizeToFit()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("SeguePushViewController 뷰가 나타날 것이다. (viewWillAppear)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SeguePushViewController 뷰가 나타났다. (viewDidAppear)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SeguePushViewController 뷰가 사라질 것이다. (viewWillDisappear)")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SeguePushViewController 뷰가 사라졌다. (viewDidDisappear)")
    }

    @IBAction func tapBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
