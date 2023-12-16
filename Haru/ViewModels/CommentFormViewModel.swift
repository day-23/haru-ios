//
//  CommentFormViewModel.swift
//  Haru
//
//  Created by 이준호 on 2023/05/13.
//

import Foundation
import UIKit

final class CommentFormViewModel: ObservableObject {
    // 댓글 작성에 필요한 필드
    @Published var content: String = ""
    @Published var x: Double?
    @Published var y: Double?

    @Published var startingX: CGFloat?
    @Published var startingY: CGFloat?

    // 댓글 편집에 필요한 필드
    @Published var textSize: [String: CGSize] = [:]
    @Published var draggingList: [String: Bool] = [:]
    @Published var xList: [String: Double] = [:]
    @Published var yList: [String: Double] = [:]

    @Published var startingXList: [String: CGFloat] = [:]
    @Published var startingYList: [String: CGFloat] = [:]

    // MARK: API

    func fetchImageComment(
        targetPostId: String,
        targetPostImageId: String,
        successAction: @escaping (_ success: [Post.Comment]) -> Void,
        failureAction: @escaping (_ failure: Error) -> Void
    ) {
        CommentService.fetchImageComment(
            targetPostId: targetPostId,
            targetPostImageId: targetPostImageId
        ) { result in
            switch result {
            case .success(let success):
                successAction(success)
            case .failure(let failure):
                failureAction(failure)
            }
        }
    }

    func createComment(
        targetPostId: String,
        targetPostImageId: String,
        successAction: @escaping () -> Void,
        failureAction: @escaping (Error) -> Void
    ) {
        CommentService.createComment(
            targetPostId: targetPostId,
            targetPostImageId: targetPostImageId,
            comment: Request.Comment(content: content, x: x, y: y)
        ) { result in
            switch result {
            case .success:
                self.content = ""
                self.x = nil
                self.y = nil
                successAction()
            case .failure(let error):
                failureAction(error)
            }
        }
    }

    func createCommentTemplate(
        targetPostId: String,
        successAction: @escaping () -> Void,
        failureAction: @escaping (Error) -> Void
    ) {
        CommentService.createCommentTemplate(
            targetPostId: targetPostId,
            comment: Request.Comment(content: content, x: x, y: y)
        ) { result in
            switch result {
            case .success:
                self.content = ""
                self.x = nil
                self.y = nil
                successAction()
            case .failure(let error):
                failureAction(error)
            }
        }
    }

    func updateCommentList(
        targetPostId: String,
        successAction: @escaping () -> Void,
        failureAction: @escaping () -> Void
    ) {
        let targetCommentIdList = Array(xList.keys)
        var xList_ = [Double]()
        var yList_ = [Double]()
        for key in targetCommentIdList {
            let x = (xList[key] ?? 190) / UIScreen.main.bounds.size.width * 100
            let y = (yList[key] ?? 190) / UIScreen.main.bounds.size.width * 100
            xList_.append(x)
            yList_.append(y)
        }

        CommentService.updateCommentList(
            targetPostId: targetPostId,
            targetCommentIdList: targetCommentIdList,
            xList: xList_,
            yList: yList_
        ) { result in
            switch result {
            case .success:
                self.clearEditing()
                successAction()
            case .failure:
                failureAction()
            }
        }
    }

    func updateComment(
        target: Post.Comment,
        successAction: @escaping () -> Void,
        failureAction: @escaping (Error) -> Void
    ) {
        CommentService.updateComment(
            targetUserId: target.user.id,
            targetCommentId: target.id,
            comment: Request.Comment(isPublic: false)
        ) { result in
            switch result {
            case .success:
                successAction()
            case .failure(let failure):
                failureAction(failure)
            }
        }
    }

    func deleteComment(
        target: Post.Comment,
        successAction: @escaping () -> Void,
        failureAction: @escaping (Error) -> Void
    ) {
        CommentService.deleteComment(
            targetUserId: target.user.id,
            targetCommentId: target.id
        ) { result in
            switch result {
            case .success:
                successAction()
            case .failure(let failure):
                failureAction(failure)
            }
        }
    }

    func clearEditing() {
        xList = [:]
        yList = [:]
        startingXList = [:]
        startingYList = [:]
        draggingList = [:]
    }
}
