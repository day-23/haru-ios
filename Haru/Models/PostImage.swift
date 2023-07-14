//
//  PostImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import Foundation
import SwiftUI

struct PostImage: Identifiable {
    let url: String
    let mimeType: String
    var data: Data? = nil
}

extension PostImage {
    var id: String { url }
}

extension PostImage: Hashable {}
