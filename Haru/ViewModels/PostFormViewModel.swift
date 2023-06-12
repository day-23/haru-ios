//
//  PostFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/11.
//

import Foundation
import UIKit

final class PostFormViewModel: ObservableObject {
    var postOption: PostAddMode

    @Published var content: String = ""
    @Published var imageList: [UIImage] = []
    @Published var oriImageList: [UIImage] = []

    @Published var tag: String = ""
    @Published var tagList: [Tag] = []

    @Published var templateIdList: [String?] = []
    @Published var templateTextColor: String? = nil

    @Published var templateList: [PostImage?] = []

    init(postOption: PostAddMode) {
        self.postOption = postOption

        if postOption == .writing {
            fetchTemplate()
        }
    }

    private var postService: PostService = .init()

    func fetchTemplateImage(templateImageUrlList: [String]) {
        DispatchQueue.global().async {
            templateImageUrlList.enumerated().forEach { idx, urlString in
                if let uiImage = ImageCache.shared.object(forKey: urlString as NSString) {
                    DispatchQueue.main.async {
                        self.templateList[idx] = PostImage(url: urlString, uiImage: uiImage)
                    }
                } else {
                    guard
                        let url = URL(string: urlString.encodeUrl()!),
                        let data = try? Data(contentsOf: url),
                        let uiImage = UIImage(data: data)
                    else {
                        print("[Error] \(urlString)이 잘못됨 \(#fileID) \(#function)")
                        return
                    }

                    ImageCache.shared.setObject(uiImage, forKey: urlString as NSString)
                    DispatchQueue.main.async {
                        self.templateList[idx] = PostImage(url: urlString, uiImage: uiImage)
                    }
                }
            }
        }
    }

    func fetchTemplate() {
        postService.fetchTemplate { result in
            switch result {
            case .success(let success):
                self.templateList = Array(repeating: nil, count: success.count)
                self.fetchTemplateImage(
                    templateImageUrlList: success.map { data in
                        data.url
                    }
                )

                self.templateIdList = success.map { data in
                    data.id
                }

            case .failure(let failure):
                print("[Debug] \(failure) \(#file) \(#function)")
            }
        }
    }

    func createPost(templateIdx: Int = 0, completion: @escaping (Result<Bool, Error>) -> Void) {
        switch postOption {
        case .drawing:
            postService.createPostWithImages(imageList: imageList, content: content, tagList: tagList) { result in
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        case .writing:
            guard let templateId = templateIdList[templateIdx] else {
                print("[Debug] templateId가 잘못되었습니다. \(#fileID) \(#function)")
                return
            }

            postService.createPostWithTemplate(
                templateId: templateId,
                templateTextColor: templateTextColor ?? "#191919",
                content: content,
                tagList: tagList
            ) { result in
                switch result {
                case .success:
                    completion(.success(true))
                case .failure(let failure):
                    completion(.failure(failure))
                }
            }
        }
    }
}
