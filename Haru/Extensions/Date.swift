//
//  Date.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import Foundation

public extension Date {
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
        
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
        
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    internal func getAllDates() -> [Date] {
        let calendar = Calendar.current

        // getting start Date ...
        let startDate = startOfMonth()
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        // getting date...
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    internal func startOfMonth() -> Date {
        let calendar = Calendar.current
        return calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
    }
    
    internal func endOfMonth() -> Date {
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth())!
    }
    
    internal func distance(to other: Date) -> TimeInterval {
        other.timeIntervalSinceReferenceDate - timeIntervalSinceReferenceDate
    }

    internal func advanced(by n: TimeInterval) -> Date {
        self + n
    }
}
