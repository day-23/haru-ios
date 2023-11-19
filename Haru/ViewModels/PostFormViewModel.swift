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
    @Published var imageList: [UIImage] = [] // 크롭된 이미지 리스트 (서버로 전송될 데이터)
    var oriImageList: [UIImage] = [] // 원본 이미지 리스트

    @Published var tag: String = ""
    @Published var tagList: [Tag] = []

    @Published var templateIdList: [String?] = []
    @Published var templateTextColor: String? = nil

    @Published var templateUrlList: [URL?] = []

    init(postOption: PostAddMode) {
        self.postOption = postOption

        if postOption == .writing {
            fetchTemplate()
        }
    }

    func fetchTemplate() {
        PostService.fetchTemplate { result in
            switch result {
            case .success(let success):
                self.templateUrlList = success.map { URL.encodeURL($0.url) }

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
            PostService.createPostWithImages(imageList: imageList, content: content, tagList: tagList) { result in
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

            PostService.createPostWithTemplate(
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
