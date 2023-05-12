//
//  ImageCache.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}
