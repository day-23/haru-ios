//
//  URL.swift
//  Haru
//
//  Created by 최정민 on 2023/07/14.
//

import Foundation

extension URL {
    static func encodeURL(_ url: String) -> URL? {
        return URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
    }
}
