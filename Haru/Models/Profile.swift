//
//  Profile.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Foundation

struct Profile {
    
}

struct ProfileImage: Identifiable, Codable {
    let id: String
    let originalName: String
    var url: String
    let mimeType: String
}
