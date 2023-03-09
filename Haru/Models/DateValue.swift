//
//  DateValue.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import Foundation

struct DateValue: Identifiable, Hashable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
    var isPrevDate: Bool = false    // 이전 달의 날인가?
    var isNextDate: Bool = false    // 다음 달의 날인가?
}

// MARK: - Extensions
