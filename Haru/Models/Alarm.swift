//
//  Alarm.swift
//  Haru
//
//  Created by 최정민 on 2023/03/13.
//

import Foundation

struct Alarm: Identifiable, Codable {
    //  MARK: - Properties

    let id: String
    private(set) var time: Date
}
