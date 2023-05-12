//
//  PostImage.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import SwiftUI
import Foundation

struct PostImage: Identifiable {
    let url: String
    let uiImage: UIImage
}

extension PostImage {
    var id: String { url }
}

extension PostImage: Hashable {}
