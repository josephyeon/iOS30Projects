//
//  SeguePresentViewController.swift
//  ScreenTransitionExample
//
//  Created by 정현준 on 2021/12/10.
//

import UIKit

class SeguePresentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tapBackButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
