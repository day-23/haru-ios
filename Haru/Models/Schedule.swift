//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

struct Schedule: Identifiable {
    let id = UUID().uuidString
    private(set) var content: String // 일정 제목
    private(set) var memo: String
    private(set) var startTime: Date // 일정 시작 시간
    private(set) var endTime: Date // 일정 종료 시간
    // TODO: repeatOption 물어보기
}
