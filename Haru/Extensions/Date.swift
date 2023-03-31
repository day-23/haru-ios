//
//  Date.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//  Updated by 최정민 on 2023/03/31.
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
        let startDate = self.startOfMonth()
        
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
        Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    internal func distance(to other: Date) -> TimeInterval {
        other.timeIntervalSinceReferenceDate - timeIntervalSinceReferenceDate
    }

    internal func advanced(by n: TimeInterval) -> Date {
        self + n
    }
    
    func isEqual(other: Date) -> Bool {
        self.day == other.day && self.month == other.month && self.year == other.year
    }
    
    func subtractDay() -> Date {
        guard let result = Calendar.current.date(byAdding: .day, value: -1, to: self) else { return self }
        return result
    }
    
    func addDay() -> Date {
        guard let result = Calendar.current.date(byAdding: .day, value: 1, to: self) else { return self }
        return result
    }
    
    func diffToMinute(other: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: self, to: other)
        
        let minutes = components.minute
        
        return abs(minutes!)
    }
    
    static func thisWeek() -> [Date] {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)
        ) else {
            return []
        }

        var datesOfWeek: [Date] = []
        for i in 0 ... 6 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            datesOfWeek.append(date)
        }
        return datesOfWeek
    }
    
    func indexOfWeek() -> Int? {
        let calendar = Calendar.current
        guard let startOfWeek = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        ) else {
            return nil
        }

        var datesOfWeek: [Date] = []
        for i in 0 ... 6 {
            let date = calendar.date(byAdding: .day, value: i, to: startOfWeek)!
            datesOfWeek.append(date)
        }
        return datesOfWeek.firstIndex(where: { $0.compare(self) == .orderedSame })
    }
    
    internal func localization(dateFormat: String = Constants.dateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = .localizedStringWithFormat(dateFormat)
        
        let localizedString = formatter.string(from: self)
        let localized = formatter.date(from: localizedString)
        return localized
    }

    internal func relative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }
}
