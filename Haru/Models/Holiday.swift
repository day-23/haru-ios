//
//  Holiday.swift
//  Haru
//
//  Created by 최정민 on 2023/05/09.
//

import Foundation

struct Holiday: Codable {
    let id: String
    let content: String
    let repeatStart: Date
    let repeatEnd: Date
}
