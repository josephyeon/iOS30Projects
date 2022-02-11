//
//  Diary.swift
//  06-Diary
//
//  Created by 정현준 on 2022/01/21.
//


// MARK: 일기 작성화면에서 작성된 일기가 CollectionView에 표시되도록 구현
import Foundation

// 일기 내용을 묶어내기 위한 Diary 구조체 생성
struct Diary {
    // 고유 아이디 추가하기! .. 일기 삭제시 즐겨찾기 목록과의 인덱스가 안맞아 index out of range 오류가 발생함!
    var uuidString: String

    var title: String // 일기 제목
    var contents: String // 일기 내용
    var date: Date // 작성 일자
    var isStar: Bool // 즐겨찾기 등록 여부



}
