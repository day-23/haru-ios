//
//  Date.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import Foundation

extension Date {
    func getAllDates() -> [Date] {
        let calendar = Calendar.current

        // getting start Date ...
        let startDate = startOfMonth()
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date...
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
}
