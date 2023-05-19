//
//  CommentView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import SwiftUI

struct CommentView: View {
    @Environment(\.dismiss) var dismissAction
    let deviceSize = UIScreen.main.bounds.size

    var postId: String
    @State var postImageList: [Post.Image]
    var imageList: [PostImage?]
    var commentList: [[Post.Comment]] { // [pageNum][commentIdx]
        var result = Array(repeating: [Post.Comment](), count: postImageList.count)
        for (idx, image) in postImageList.enumerated() {
            result[idx].append(contentsOf: image.comments.compactMap {
                Post.Comment(id: $0.id, user: $0.user, content: $0.content, x: $0.x / 100 * deviceSize.width, y: $0.y / 100 * deviceSize.width, createdAt: $0.createdAt)
            })
        }
        return result
    }

    @State var postPageNum: Int = 0

    var alreadyComment: [(Post.Comment, Int)?] {
        var result: [(Post.Comment, Int)?] = Array(repeating: nil, count: postImageList.count)
        for (pageNum, image) in postImageList.enumerated() {
            for (idx, comment) in image.comments.enumerated() {
                if comment.user.id == Global.shared.user?.id {
                    result[pageNum] = (
                        Post.Comment(
                            id: comment.id,
                            user: comment.user,
                            content: comment.content,
                            x: comment.x / 100 * deviceSize.width,
                            y: comment.y / 100 * deviceSize.width,
                            createdAt: comment.createdAt
                        ),
                        idx
                    )
                }
            }
        }
        return result
    }

    @State var isCommentCreate: Bool = false

    @State var textRect = CGRect()

    // For Gesture
    @State var overDelete: Bool = false
    @State var dragging: Bool = false
    @State var pressing: Bool = false

    @FocusState var isFocused: Bool

    @State var delCommentModalVis: Bool = false
    @State var delCommentTarget: Post.Comment?

    // 댓글 작성에 필요한 필드
    @State var content: String = ""
    @State var x: Double?
    @State var y: Double?

    @State var startingX: CGFloat?
    @State var startingY: CGFloat?

    var isMine: Bool

    // For API
    private let commentService: CommentService = .init()

    var body: some View {
        ZStack {
            Text("\(postPageNum + 1)/\(postImageList.count)")
                .font(.pretendard(size: 14, weight: .bold))
                .foregroundColor(Color(0xFDFDFD))
                .offset(y: -250)

            mainContent(deviceSize: deviceSize)
                .zIndex(3)

            if delCommentModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(4)
                    .onTapGesture {
                        withAnimation {
                            delCommentModalVis = false
                        }
                    }

                Modal(isActive: $delCommentModalVis, ratio: 0.4) {
                    VStack(spacing: 12) {
                        if let target = delCommentTarget {
                            if let profileImage = target.user.profileImage {
                                ProfileImgView(imageUrl: URL(string: profileImage))
                                    .frame(width: 70, height: 70)
                            } else {
                                Image("default-profile-image")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 70, height: 70)
                            }
                            Text(target.user.name)
                                .font(.pretendard(size: 20, weight: .bold))
                            Text("댓글을 정말로 삭제하시겠습니까?")
                                .font(.pretendard(size: 16, weight: .regular))

                            Spacer()
                                .frame(height: 30)

                            HStack {
                                Button {
                                    delCommentModalVis = false
                                } label: {
                                    Text("취소")
                                        .font(.pretendard(size: 20, weight: .regular))
                                }

                                Spacer()

                                Button {
                                    print("targetCommentId: \(target.id)")
                                    commentService.deleteComment(
                                        targetUserId: target.user.id,
                                        targetCommentId: target.id
                                    ) { result in
                                        switch result {
                                        case .success(let success):
                                            delCommentModalVis = !success
                                            if success {
                                                postImageList[postPageNum].comments = postImageList[postPageNum].comments.filter {
                                                    $0.id != delCommentTarget?.id
                                                }
                                            }
                                        case .failure(let failure):
                                            print("[Debug] \(failure)")
                                        }
                                    }
                                } label: {
                                    Text("확인")
                                        .font(.pretendard(size: 20, weight: .regular))
                                        .foregroundColor(Color(0xF71E58))
                                }
                            }
                            .padding(.horizontal, 60)
                        }
                    }
                    .padding(.top, 20)
                }
                .transition(.modal)
                .zIndex(5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(0x191919))
        .edgesIgnoringSafeArea(.top)
        .simultaneousGesture(
            TapGesture().onEnded {
                if isFocused {
                    isFocused = false
                }
            }
        )
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if isCommentCreate {
                        isCommentCreate = false
                        content = ""
                    } else {
                        dismissAction.callAsFunction()
                    }
                } label: {
                    Image("cancel")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(0xFDFDFD))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("코멘트 남기기")
                    .font(.pretendard(size: 14, weight: .regular))
                    .foregroundColor(Color(0xFDFDFD))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if isCommentCreate {
                    Button {
                        if let comment = alreadyComment[postPageNum] {
                            commentService.updateComment(
                                targetUserId: comment.0.user.id,
                                targetCommentId: comment.0.id,
                                comment: Request.Comment(content: content, x: x, y: y)
                            ) { result in
                                switch result {
                                case .success(let success):
                                    print("수정 완료")
                                    // 댓글 업데이트 시 필드 값 변경해주기
                                    postImageList[postPageNum].comments[comment.1].content = content
                                    if let x, let y {
                                        postImageList[postPageNum].comments[comment.1].x = x / deviceSize.width * 100
                                        postImageList[postPageNum].comments[comment.1].y = y / deviceSize.width * 100
                                    }
                                    isFocused = false
                                    isCommentCreate = false
                                case .failure(let failure):
                                    print("[Debug] \(failure)")
                                    print("\(#function)")
                                }
                            }
                        } else {
                            commentService.createComment(
                                targetPostId: postId,
                                targetPostImageId: postImageList[postPageNum].id,
                                comment: Request.Comment(content: content, x: x, y: y)
                            ) { result in
                                switch result {
                                case .success(let success):
                                    content = ""
                                    x = nil
                                    y = nil
                                    postImageList[postPageNum].comments.append(success)
                                    isCommentCreate = false
                                case .failure(let failure):
                                    print("[Debug] \(failure)")
                                    print("\(#fileID) \(#function)")
                                }
                            }
                        }
                    } label: {
                        Image("confirm")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFDFDFD))
                    }
                } else {
                    Button {} label: {
                        Image("option-button")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFDFDFD))
                    }
                }
            }
        }
    }

    @ViewBuilder
    func mainContent(deviceSize: CGSize) -> some View {
        let sz = deviceSize.width
        let longPress = LongPressGesture(minimumDuration: 0.3)
            .onEnded { value in
                withAnimation {
                    dragging = true
                }
            }

        let drag = DragGesture()
            .onChanged { value in
                // 삭제 버튼 근처인 경우
                if value.location.x >= sz / 2 - 45,
                   value.location.x <= sz / 2 + 45,
                   value.location.y >= sz + 25,
                   value.location.y <= sz + 120
                {
                    overDelete = true
                } else {
                    overDelete = false
                }

                // 범위 막기
                if value.location.y < 0 {
                    return
                }

                if value.location.x + textRect.width / 2 >= sz - 15 ||
                    value.location.x - textRect.width / 2 <= 15 ||
                    value.location.y - textRect.height / 2 <= 15
                {
                    return
                } else {
                    x = value.location.x
                    y = value.location.y
                }
            }
            .onEnded { value in
                if overDelete {
                    isCommentCreate = false
                    content = ""
                    overDelete = false
                }
                if value.location.y + textRect.height / 2 > sz - 5 {
                    x = startingX ?? 190
                    y = startingY ?? 190
                }
                withAnimation {
                    dragging = false
                }
            }

        let combined = longPress.sequenced(before: drag)

        GeometryReader { proxy in
            ZStack {
                if isCommentCreate {
                    Color.black.opacity(0.3)
                        .zIndex(3)
                }

                postListView()
                    .zIndex(1)

                commentListView()

                if isCommentCreate {
                    ZStack {
                        Circle()
                            .frame(width: overDelete ? 90 : 80, height: overDelete ? 90 : 80)
                            .foregroundColor(overDelete ? Color(0xF71E58) : .gray2)

                        Image("cancel")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 38, height: 38)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: 80 + 30)
                    .zIndex(2)
                }
            }
            .onTapGesture { location in
                if isMine || isCommentCreate {
                    return
                }

                // 기존에 댓글을 작성했는지 처음 작성인지 판별
                if let comment = alreadyComment[postPageNum] {
                    x = CGFloat(comment.0.x)
                    y = CGFloat(comment.0.y)
                    startingX = CGFloat(comment.0.x)
                    startingY = CGFloat(comment.0.y)
                    content = comment.0.content
                } else {
                    x = location.x
                    y = location.y
                    startingX = location.x
                    startingY = location.y
                }

                isCommentCreate = true
                isFocused = true
            }

            if isCommentCreate, let x, let y {
                TextFieldDynamicWidth(title: "        ", text: $content, textRect: $textRect) { editingChange in
                    // logic
                } onCommit: {
                    // logic
                }
                .lineLimit(4)
                .focused($isFocused)
                .font(.pretendard(size: dragging ? 18 : 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(0xFDFDFD))
                .cornerRadius(9)
                .position(x: x, y: y)
                .zIndex(4)
                .onTapGesture {
                    isFocused = true
                }
                .simultaneousGesture(
                    combined
                )
            }
        }
        .frame(
            width: deviceSize.width,
            height: deviceSize.width
        )
    }

    @ViewBuilder
    func commentListView() -> some View {
        ForEach(commentList[postPageNum]) { comment in
            if !isCommentCreate || alreadyComment[postPageNum]?.0.id != comment.id {
                Text("\(comment.content)")
                    .font(.pretendard(size: 14, weight: .bold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(0xFDFDFD))
                    .cornerRadius(9)
                    .position(x: CGFloat(comment.x), y: CGFloat(comment.y))
                    .foregroundColor(Color(0x191919))
                    .zIndex(2)
                    .onTapGesture {
                        if isMine {
                            delCommentTarget = comment
                            delCommentModalVis = true
                        }
                    }
            }
        }
    }

    @ViewBuilder
    func postListView() -> some View {
        TabView(selection: $postPageNum) {
            ForEach(imageList.indices, id: \.self) { idx in
                if let uiImage = imageList[idx]?.uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    ProgressView()
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}
