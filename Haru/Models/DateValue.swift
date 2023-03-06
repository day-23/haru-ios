//
//  DateValue.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import Foundation

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
    var isPrevDate: Bool = false
}

// MARK: - Extensions
