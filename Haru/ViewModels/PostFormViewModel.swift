//
//  PostFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/11.
//

import Foundation
import UIKit

final class PostFormViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var imageList: [UIImage] = []

    @Published var tag: String = ""
    @Published var tagList: [Tag] = []

    @Published var templateURL: String?

    private var postService: PostService = .init()

    func createPost(completion: @escaping () -> Void) {
        if let templateURL {
        } else {
            postService.createPostWithImages(imageList: imageList, content: content, tagList: tagList) { result in
                switch result {
                case .success:
                    completion()
                case .failure(let failure):
                    print("[Debug] \(failure) \(#fileID) \(#function)")
                }
            }
        }
    }
}
