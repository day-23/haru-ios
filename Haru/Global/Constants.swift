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
    static let baseURL = "https://api.23haru.com/"
//    static let baseURL = "http://192.168.0.42:3000/"

    static let gradientStart = Color(0x53acf8)
    static let gradientEnd = Color(0x9da6f5)
}
