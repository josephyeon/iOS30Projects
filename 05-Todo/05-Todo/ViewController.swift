//
//  ViewController.swift
//  05-Todo
//
//  Created by 정현준 on 2022/01/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem! // Edit 버튼이 메모리상에서 해제되어 재사용이 불가능한 경우를 막기 위해 storage를 strong으로 설정

    // Edit 버튼을 눌렀을 때 Done으로 변하게 설정하기 위해 우선 프로퍼티 생성
    var doneButton: UIBarButtonItem?

    // 할 일 목록 저장하는 배열 생성
    // 프로퍼티 옵저버를 이용해 할 일이 추가될 때 마다 saveTasks 메서드 호출
    var tasks = [Task]() {
        didSet {
            self.saveTasks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.tableView.dataSource = self // 하단에 extension으로 UITableViewDataSource 프로토콜 선언 후 작성 -> 업데이트에 따른 UI 변화
        self.tableView.delegate = self // 하단에 extension으로 UITableViewDelegate 프로토콜 선언 후 작성 -> 값 업데이트
        self.loadTasks() // 뷰 실행시킬 때 마다 기존에 저장된 데이터 불러오기
    }

    // MARK: Done 버튼 클릭 -> Edit 모드 해제 (Done 버튼 클릭이 아니더라도 Edit 모드 해제 함수로 공통 사용 가능함)
    // viewDidLoad에서 불러올 doneButton의 콜백함수(#selector) 작성: Done 버튼을 눌렀을 때 Edit 모드 빠져나오게 구현
    @objc func doneButtonTap() {
        self.navigationItem.leftBarButtonItem = self.editButton
        self.tableView.setEditing(false, animated: true) // edit 모드 해제

    }

    // MARK: TableView의 Edit 버튼 클릭 -> Edit 모드 설정
    // edit 버튼 눌렀을 때 액션함수 생성
    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return } // 테이블 뷰가 비어있지 않을 때만 편집모드로 들어가게 설정
        self.navigationItem.leftBarButtonItem = self.doneButton
        self.tableView.setEditing(true, animated: true) // Edit 모드 설정
    }

    // MARK: 할 일을 등록하는 Alert이 표시되도록 구현
    @IBAction func tabAddButton(_ sender: UIBarButtonItem) {
        // 등록 창 구현
            // preferredStyle - actionSheet: 하단에서 올라오는 형식 / alert: 화면 가운데 뜨는 창
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)

        // 등록, 취소 버튼 구현
            // handler에 입력할 메서드를 클로저로 변환해 작성
            // [weak self]: 클로저는 참조타입이기 때문에 클로저의 본문에서 self로 인스턴스를 capturing할 때 strong 상태로 이뤄짐 -> 선언부에서 weak로 선언함으로써 메모리 누수 방지 (추후 강의)
        let registerButton = UIAlertAction(title: "등록", style: .default) { [weak self] _ in
            // 등록 버튼 눌렀을 때 텍스트 입력 값 가져오기 (guard let 이용해서 옵셔널 바인딩)
            guard let title = alert.textFields?[0].text else { return }

            // 입력 값을 Task 구조체 형식으로 변환
            let task = Task(title: title, done: false)

            // 변환 값 tasks에 추가
            self?.tasks.append(task)

            // 하단 extension에서 업데이트한 데이터를 바탕으로 reload 시키기
            self?.tableView.reloadData()
        }

        let cancelButton = UIAlertAction(title: "취소", style: .default, handler: nil) // 취소의 경우 handler를 nil로 설정

        // 구현한 버튼이 Alert 창에 나타나도록 추가
        alert.addAction(cancelButton)
        alert.addAction(registerButton)

        // Alert 창에 텍스트 입력 추가
            // configurationHandler: Alert을 표시하기 전에 TextField 구성하는 클로저
        alert.addTextField { textField in
            textField.placeholder = "할 일을 입력해주세요."
        }

        // 화면상에 나타나도록 present 메서드 실행
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: UserDefaults를 이용해 로컬에 등록한 내용을 저장하고 재실행시 불러오도록 구현
    /**
     # UserDefaults
     * 런타임 환경에서 동작
     * 앱이 실행되는 동안 저장소에 접근해 데이터를 기록하고 가져오는 역할
     * Key-value 쌍으로 저장되고, Singleton 패턴으로 설계되어 앱 전체에서 단 하나의 인스턴스로만 존재
     * 여러가지 타입 (String, Int, ...  뿐만 아니라 NS타입 데이터까지)을 저장
     */

    func saveTasks() {
        // Dictionary 타입으로 변환시켜 데이터 저장
        let data = self.tasks.map {
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        // 싱글톤 형식을 이용해 UserDefaults에 접근
        let userDefaults = UserDefaults.standard

        // set 메서드를 호출시켜 데이터 저장
        userDefaults.set(data, forKey: "tasks")
    }

    // UserDefaults에 저장된 데이터 불러오기
    func loadTasks() {
        // 싱글톤 접근
        let userDefaults = UserDefaults.standard

        // object 메서드를 이용해 저장된 데이터 접근
        // 단, Dictionary 형태로 타입캐스팅이 필요하며, optional 타입이기 때문에 optional binding 설정
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }

        // 접근한 데이터를 Tasks 형식에 맞게 변환시켜 tasks에 맵핑시킨다.
        self.tasks = data.compactMap{
            guard let title = $0["title"] as? String else { return nil }
            guard let done = $0["done"] as? Bool else { return nil }
            return Task(title: title, done: done)
        }

    }
}

// MARK: UITableViewDataSource를 이용해 TableViewCell에 무슨 데이터를 어떻게 나타낼지 설정하기
// ViewController 한번에 작성하면 복잡해보이니 extension을 이용해 따로 빼서 작성함
extension ViewController: UITableViewDataSource {
    // 테이블 뷰의 셀 개수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }

    // 테이블 뷰의 각 행마다 어떤 데이터를 표시할 것인지
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 스토리보드에서 tableViewCell의 identifier를 cell로 설정한 후 dequeReusableCell 메서드 호출
            // dequeReusableCell: 재사용 식별자(withIdentifier)에 대해 재사용 가능한 테이블 뷰 셀 객체(indexPath)를 반환하고 이를 테이블 뷰에 추가
            // (메모리 낭비 방지)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row] // row는 0부터 (tasks배열의 개수-1)가 됨 (참고: indexPath는 section과, row로 구성)
        cell.textLabel?.text = task.title // cell에 title 입력시키기

        // 할 일이 완료된 상태면, 체크마크가 생기도록 accessoryType을 이용해 구현 (하단 Delegate 작성 후 구현)
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    // MARK: Edit 모드에서 데이터 삭제 구현
    // commit 메서드를 이용: 삭제 버튼이 눌린 셀이 어떤 것인지 (forRowAt) 파악
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row) // tasks에서 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) // 해당 데이터가 있던 Row도 삭제

        // tasks가 비어있는 경우 Edit 모드 빠져나오기
        if self.tasks.isEmpty { self.doneButtonTap() }
    }

    // MARK: Edit 모드에서 순서 변경 구현
    // canMoveRowAt 메서드: move 가능하도록 true 반환
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // moveRowAt 메서드를 이용: 어디서 어디로 이동되었는지(sourceIndexPath -> destinationIndexPath) 파악
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // 복사 -> 삭제 -> 삽입 -> 덮어 씌우기
        var tasks = self.tasks // self.tasks에 바로 접근하지 말고 새 프로퍼티에 복사해서 변경할 것!
        let task = tasks[sourceIndexPath.row]
        tasks.remove(at: sourceIndexPath.row) // 기존 위치에 삭제
        tasks.insert(task, at: destinationIndexPath.row) // 옮길 위치로 삽입
        self.tasks = tasks // 덮어쓰기
    }
}

// MARK: 할 일이 완료된 Task는 cell을 클릭했을 때 체크마크가 표시되도록 구현
extension ViewController: UITableViewDelegate {
    // 어떤 cell이 선택되었는지 알려주는 메서드 -> 선택 여부에 따라 done을 true/false로 변경시키도록 구현
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done // 선택되면 done 상태 바꿔주기
        self.tasks[indexPath.row] = task // 원래 배열 요소에 덮어 씌우기

        // 덮어 쓴 cell만 reload하도록 구현
        // at: [IndexPath]이기 때문에 여러개의 행을 받아서 업데이트도 가능하다는 것 유념
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
