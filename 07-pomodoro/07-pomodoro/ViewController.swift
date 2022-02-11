//
//  ViewController.swift
//  07-pomodoro
//
//  Created by 정현준 on 2022/01/22.
//

import UIKit
import AudioToolbox // 타이머가 완료되면 알람 울리기 위해

// 타이머 상태 열거값
enum TimerStatus {
    case start
    case pause
    case end
}

class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!

    @IBOutlet weak var imageView: UIImageView!
    
    var duration = 60 // App이 실행되면 datePicker가 기본적으로 1분으로 설정되기 때문에 60으로 초기화
    var timerStatus: TimerStatus = .end // 타이머 상태 프로퍼티
    var timer: DispatchSourceTimer?
    var currentSeconds = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }

    // 토글 버튼 눌렀을 때 타이머, 진행 바 hidden 여부 설정하기
    func setTimerInfoViewVisible(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }

    // 버튼의 상태에 따라 버튼 타이틀이 바뀌게 설정
    // 노멀상태 - 시작 / 선택된 상태 - 일시정지
    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }

    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else {return}
                self.currentSeconds -= 1

                // 타이머 레이블 변화시키기
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600) / 60
                let seconds = (self.currentSeconds % 3600) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconds)

                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                UIView.animate(withDuration: 0.5, delay: 0) { // 토마토 이미지 180도 회전시키기
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                }
                UIView.animate(withDuration: 0.5, delay: 0.5) { // 토마토 이미지 회전후 한번 더 360도 회전시키기
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                }
                // 타이머 바 변화시키기
                if self.currentSeconds <= 0 { // 타이머가 다 끝났을 때
                    self.stopTimer() // 타이머가 종료
                    AudioServicesPlaySystemSound(1005) // iphone.dev.wiki에서 soundID를 확인할 수 있다.
                }
            })
            self.timer?.resume()
        }
    }

    func stopTimer() { // 타이머 종료
        if self.timerStatus == .pause {
            // 공식문서에 따르면 pause 상태에서 타이머를 종료시킬시 suspend 오류가 발생한다
            // 일시정지상태에서는 resume을 한번 시켜주고 취소시켜야 한다.
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        UIView.animate(withDuration: 0.5) {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        }
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil // 꼭 nil을 할당하여 메모리에서 해제시켜야 함!
    }

    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()

        default:
            break
        }
    }

    @IBAction func tapToggleButton(_ sender: UIButton) {
        // countDownDuration은 초단위로 시간을 반환
        // TimeInterval 타입이기 때문에 Int로 변경해서 반환
        self.duration = Int(self.datePicker.countDownDuration)

        // 각 상태별로 시작버튼을 눌렀을 때
        // setTimerInfoViewVisible 함수 및 datePicker 숨김여부 설정
        switch self.timerStatus {
        case .end: // 타이머 종료 상태에서 토글 -> 시작으로 변경
            self.currentSeconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5) {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            }
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()

        case .start: // 타이머 실행 상태에서 토글 -> 일시정지로 변경
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()


        case .pause: // 일시정지 상태에서 토글 -> 시작으로 변경
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
        }
    }
}

