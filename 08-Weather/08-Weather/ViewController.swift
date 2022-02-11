//
//  ViewController.swift
//  08-Weather
//
//  Created by 정현준 on 2022/01/22.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var cityNameTextField: UITextField!

    @IBOutlet weak var cityNameLabel: UILabel!

    @IBOutlet weak var weatherDescriptionLabel: UILabel!

    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!

    @IBOutlet weak var weatherStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func tapFetchWeatherButton(_ sender: UIButton) {
        if let cityName = self.cityNameTextField.text {
            self.getCurrentWeather(cityName: cityName)
            self.view.endEditing(true)
        }
    }

    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name
        if let weather = weatherInformation.weather.first{
            self.weatherDescriptionLabel.text = weather.description
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃"
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃"
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃"
    }

    // Alert 나타내기 함수: 에러 메세지를 Alert로 나타내기 위한 용도
    func showAlert(message: String) {
        let alert = UIAlertController(title: "에러발생!", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=b71ed4c8d5ce70f514fd606740479b35") else { return }
        let session = URLSession(configuration: .default)
        session.dataTask(with: url) { [weak self] data, response, error in
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder()

            // 응답 코드가 successRange에 속하는 경우에만 날씨 정보 불러옴
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return }
                DispatchQueue.main.async { // 현재 날씨정보가 뷰에 표시되도록 비동기를 이용해 구현
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInformation: weatherInformation)
                }
            } else { // 응답 실패한 경우 에러 메세지 출력
                // 응답 실패 메세지를 ErrorMessage 구조체로 디코딩하여 저장
                guard let errorMessage = try? decoder.decode(ErrorMessage.self, from: data) else { return }
                DispatchQueue.main.async {
                    // 저장된 메세지를 Alert로 나타냄
                    self?.showAlert(message: errorMessage.message)
                }
            }
        }.resume()
    }
}

