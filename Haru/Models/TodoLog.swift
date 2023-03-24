//
//  TodoLog.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

struct TodoLog {
    let id: String
    let createdAt: Date
    private(set) var updatedAt: Date
    private(set) var deletedAt: Date?
}
