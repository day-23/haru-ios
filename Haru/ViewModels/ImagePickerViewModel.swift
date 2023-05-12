//
//  ImagePickerViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/10.
//

import Foundation
import PhotosUI

final class ImagePickerViewModel: ObservableObject {
    // MARK: Properties

    @Published var fetchedImages: [ImageAsset] = []
    @Published var selectedImages: [ImageAsset] = []

    init() {
        fetchImages()
    }

    // MARK: Fetching Images

    func fetchImages() {
        let options = PHFetchOptions()
        options.includeHiddenAssets = false
        options.includeAssetSourceTypes = [.typeUserLibrary]
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        PHAsset.fetchAssets(with: .image, options: options).enumerateObjects { asset, _, _ in
            let imageAsset: ImageAsset = .init(asset: asset)
            self.fetchedImages.append(imageAsset)
        }
    }
}
