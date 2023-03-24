//
//  RepeatOption.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import Foundation

enum RepeatError: Error {
    case invalid
    case calculation
}

enum RepeatOption: String, CaseIterable {
    case everyDay = "매일"
    case everyWeek = "매주"
    case everySecondWeek = "2주마다"
    case everyMonth = "매달"
    case everyYear = "매년"
}
