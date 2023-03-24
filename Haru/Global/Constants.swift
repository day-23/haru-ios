//
//  Constants.swift
//  Haru
//
//  Created by 최정민 on 2023/03/08.
//

import Foundation
import SwiftUI

struct Constants {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    static let dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.iso8601
    static let dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.iso8601
    static let baseURL = "http://localhost:8000/"

    static let gradientStart = Color(0x53ACF8)
    static let gradientEnd = Color(0x9DA6F5)
    static let lightGray = Color(0x000000, opacity: 0.3)
}
