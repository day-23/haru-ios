//
//  StringHelper.swift
//  Haru
//
//  Created by 이준호 on 2023/06/03.
//

import Foundation

final class StringHelper {
    class func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.compactMap {
                Range($0.range, in: text).map { String(text[$0]) }
            }
        } catch {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }

    class func insensitiveSame(str1: String, str2: String) -> Bool {
        str1.caseInsensitiveCompare(str2) == .orderedSame
    }
}
