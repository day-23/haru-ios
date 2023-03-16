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
    private(set) var repeatWeek: String?
    private(set) var repeatMonth: String?
    private(set) var repeatStart: Date
    private(set) var repeatEnd: Date
    
    private(set) var timeOption: Bool
            
    private(set) var category: Category?
    
    private(set) var alarms: [Alarm]
    
    
    // MARK: - Dates
    
    let createdAt: Date
    let updatedAt: Date?
}

// MARK: - extension
