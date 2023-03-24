//
//  Data.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import Foundation

extension Data {
    func hexEncodedString() -> String {
        map { String(format: "%02hhx", $0) }.joined()
    }
}
