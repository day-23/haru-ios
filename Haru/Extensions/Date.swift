//
//  Date.swift
//  Haru
//
//  Created by 최정민 on 2023/03/10.
//

import Foundation

extension Date {
    func localization(dateFormat: String = Constants.dateFormat) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = .localizedStringWithFormat(dateFormat)
//        formatter.locale = Locale(identifier: Locale.current.identifier)
//        formatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)

        let localizedString = formatter.string(from: self)
        let localized = formatter.date(from: localizedString)
        return localized
    }

    func relative() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }
}
