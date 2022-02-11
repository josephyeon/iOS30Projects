//
//  ViewController.swift
//  04-Calculator
//
//  Created by 정현준 on 2021/12/16.
//

import UIKit

// 연산자 정보를 담은 enum 타입 생성
// Operation에 관한 함수를 ViewController 클래스 내부에 생성한다
enum Operation {
    case Add
    case Subtract
    case Divide
    case Multiply
    case unknown
}

class ViewController: UIViewController {

    @IBOutlet weak var numberOutputLabel: UILabel!

    var displayNumber = ""
    var firstOperand = ""
    var secondOperand = ""
    var result = ""
    var currentOperation: Operation = .unknown

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapNumberButton(_ sender: UIButton) {
        guard let numberValue = sender.title(for: .normal) else { return }
        // 9자리까지만 입력하도록 설정
        if self.displayNumber.count < 9 {
            self.displayNumber += numberValue
            self.numberOutputLabel.text = self.displayNumber
        }
    }

    @IBAction func tapClearButton(_ sender: UIButton) {
        self.displayNumber = ""
        self.firstOperand = ""
        self.secondOperand = ""
        self.result = ""
        self.currentOperation = .unknown
        self.numberOutputLabel.text = "0"
    }

    @IBAction func tapDotButton(_ sender: UIButton) {
        // 9자리까지만 입력 가능 -> 소수점 입력 공간 제외하면 숫자는 8자리까지만 입력 가능
        // 그리고 소숫점(.)이 사전에 포함되어있지 않은 상태여야 함
        if self.displayNumber.count < 8, !self.displayNumber.contains(".") {
            self.displayNumber += self.displayNumber.isEmpty ? "0." : "." // 삼항연산자: 아무것도 안적힌 경우 -> 0.x로 시작하게 설정
            self.numberOutputLabel.text = self.displayNumber
        }
    }

    @IBAction func tapDivideButton(_ sender: UIButton) {
        self.operation(.Divide)

    }

    @IBAction func tapMultiplyButton(_ sender: UIButton) {
        self.operation(.Multiply)
    }

    @IBAction func tapSubtractButton(_ sender: UIButton) {
        self.operation(.Subtract)
    }

    @IBAction func tapAddButton(_ sender: UIButton) {
        self.operation(.Add)
    }

    @IBAction func tapEqualButton(_ sender: UIButton) {
        self.operation(self.currentOperation)
    }

    // 연산자 버튼 작성 전에 계산 담당 함수 먼저 생성: Operation 타입을 받는 연산함수
    func operation(_ operation: Operation) {
        if self.currentOperation != .unknown {
            if !self.displayNumber.isEmpty {
                self.secondOperand = self.displayNumber
                self.displayNumber = ""

                guard let firstOperand = Double(self.firstOperand) else { return }
                guard let secondOperand = Double(self.secondOperand) else { return }

                switch self.currentOperation {
                case .Add:
                    self.result = "\(firstOperand + secondOperand)"

                case .Subtract:
                    self.result = "\(firstOperand - secondOperand)"

                case .Multiply:
                    self.result = "\(firstOperand * secondOperand)"

                case .Divide:
                    self.result = "\(firstOperand / secondOperand)"

                default:
                    break
                }

                // 소숫점까지 계산 결과 안나와도 되는 경우에는 Int형으로 출력시키도록 설정
                if let result = Double(self.result), result.truncatingRemainder(dividingBy: 1) == 0 {
                    self.result = "\(Int(result))"
                }

                self.firstOperand = self.result
                self.numberOutputLabel.text = self.result
            }
            self.currentOperation = operation
        } else {
            self.firstOperand = self.displayNumber
            self.currentOperation = operation
            self.displayNumber = "" // 새로 더할 연산할 숫자를 나타내기 위해 비워두기
        }

    }

}

