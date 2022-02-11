//
//  CardListViewController.swift
//  11-CreditCardList
//
//  Created by 정현준 on 2022/01/25.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseFirestore
import CoreMedia

class CardListViewController: UITableViewController {

//    var ref: DatabaseReference! // Firebase Realtime Database

    var db = Firestore.firestore()

    var creditCardList: [CreditCard] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // UITableViewCell를 .xib 파일을 이용해 등록
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")

        // 실시간 데이터베이스 읽기
//        ref = Database.database().reference()
//        ref.observe(.value) { snapshot in
//            guard let value = snapshot.value as? [String: [String: Any]] else { return }
//
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: value)
//                let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
//                let cardList = Array(cardData.values)
//                self.creditCardList = cardList.sorted{ $0.rank < $1.rank}
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            } catch let error {
//                print("ERROR JSON PARSING \(error.localizedDescription)")
//            }
//        }

        // Firestore에서 읽기
        db.collection("creditCardList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("ERROR FIRESTORE FETCHING DOCUMENT \(String(describing: error))")
                return
            }
            self.creditCardList = documents.compactMap({ doc -> CreditCard? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData)
                    return creditCard
                } catch let error {
                    print("ERROR JSON PARSING \(error)")
                    return nil
                }
            }).sorted(by: { $0.rank < $1.rank })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
        cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"

        // 사진 URL을 이용하여 신용카드 사진 넣어주기
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)

        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 상세 화면 전달
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "CardDetailViewController") as? CardDetailViewController else { return }
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)

        // Option 1 - isSelected를 이용하여 시뮬레이터 상에서 터치시 Firebase상에서도 반응
//        let cardID = creditCardList[indexPath.row].id
//        ref.child("Item\(cardID)/isSelected").setValue(true)

        // Option 2 - reference의 queryorder
//        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let value = snapshot.value as? [String: [String: Any]],
//                  let key = value.keys.first else { return }
//
//            self.ref.child("\(key)/isSelected").setValue(true)
//        }

    }

    // Option 3 - 데이터베이스 삭제 => firebase에선 removeValue 함수 제공
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // case 1) cardID를 통해 경로를 알고 있을 때
//            let cardID = creditCardList[indexPath.row].id
//            ref.child("Item\(cardID)").removeValue()

            // case 2) 경로를 모르는 경우
            // 고유의 id값을 찾는 쿼리를 날림. 대신 id는 cardID와 일치해야 함
//            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String: [String:Any]],
//                      let key = value.keys.first else { return }
//
//                ref.child(key).removeValue()
//            }
        }
    }
}
