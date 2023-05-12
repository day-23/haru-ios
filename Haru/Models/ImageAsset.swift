//
//  ImageAsset.swift
//  Haru
//
//  Created by 이준호 on 2023/05/10.
//

import Foundation
import PhotosUI

struct ImageAsset: Identifiable {
    var id: String = UUID().uuidString
    var asset: PHAsset
    var thumbnail: UIImage?

    // MARK: Selected Image Index
    var assetIndex: Int = -1
}
