//
//  Schedule.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

struct Schedule: Identifiable, Codable {
    let id: String
    private(set) var content: String // 일정 제목
    private(set) var memo: String
    private(set) var flag: Bool
    private(set) var repeatOption: String?
    private(set) var `repeat`: String?
    private(set) var repeatStart: Date
    private(set) var repeatEnd: Date
    
    private(set) var category: Category?
    
    private(set) var alarms: [Alarm]
//    private(set) var startTime: Date // 일정 시작 시간
//    private(set) var endTime: Date // 일정 종료 시간
    
    // MARK: - Dates
    let createdAt: Date
}

// MARK: - extension
