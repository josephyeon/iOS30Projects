//
//  ViewController.swift
//  ScreenTransitionExample
//
//  Created by 정현준 on 2021/12/08.
//

import UIKit

class ViewController: UIViewController, SendDataDelegate {
    @IBOutlet weak var nameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController 뷰가 로드되었다. (ViewDidLoad)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ViewController 뷰가 나타날 것이다. (viewWillAppear)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController 뷰가 나타났다. (viewDidAppear)")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController 뷰가 사라질 것이다. (viewWillDisappear)")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController 뷰가 사라졌다. (viewDidDisappear)")
    }

    @IBAction func tapCodePushButton(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "CodePushViewController") as? CodePushViewController else { return }
        vc.name = "데이터가 옮겨짐"
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func tapCodePresentButton(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(identifier: "CodePresentViewController") as? CodePresentViewController else { return }
        vc.name = "데이터가 옮겨짐"
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SeguePushViewController {
            vc.name = "Segue를 이용해 데이터 전달"
        }
    }

    func sendData(name: String) {
        self.nameLabel.text = name
        self.nameLabel.sizeToFit()
    }

}

