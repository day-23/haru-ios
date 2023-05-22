//
//  CommentFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/13.
//

import Foundation

final class CommentFormViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var x: Double?
    @Published var y: Double?

    private let commentService: CommentService = .init()

    func createComment(
        targetPostId: String,
        targetPostImageId: String,
        completion: @escaping () -> Void
    ) {
        let comment = Request.Comment(content: content, x: x, y: y)

        commentService.createComment(targetPostId: targetPostId, targetPostImageId: targetPostImageId, comment: comment) { result in
            switch result {
            case .success(let success):
                completion()
            case .failure(let failure):
                print("[Debug] \(failure)")
                print("\(#fileID) \(#function)")
            }
        }
    }
}
