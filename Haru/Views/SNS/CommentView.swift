//
//  CommentView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import Kingfisher
import SwiftUI

struct CommentView: View, KeyboardReadable {
    @Environment(\.dismiss) var dismissAction
    let deviceSize = UIScreen.main.bounds.size

    @Binding var post: Post

    var isTemplate: Bool = false
    var templateContent: String?
    var contentColor: String?

    var postId: String
    var userId: String // 게시물을 작성한 사용자 id
    @State var postImageList: [Post.Image]
    var imageUrlList: [URL?]
    @State var commentList: [[Post.Comment]]

    @State var postPageNum: Int = 0

    // 내가 이미 작성한 댓글이 있으면
    // alreadyComment[postPageNum] = (Post.Comment, Int)
    // 없으면 nil
    var alreadyComment: [(Post.Comment, Int)?] {
        var result: [(Post.Comment, Int)?] = Array(repeating: nil, count: postImageList.count)
        for (pageNum, comments) in commentList.enumerated() {
            for (idx, comment) in comments.enumerated() {
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

    @State var isCommentWriting: Bool = false // 댓글을 작성 중인가
    @State var isCommentDeleting: Bool = false // 댓글을 삭제 중인가 (자신이 작성한 댓글)
    @State var isCommentEditing: Bool = false // 댓글을 수정 중인가 (본인 게시물에서만 가능)
    @State var hideAllComment: Bool = false // 댓글을 가릴건지 안가릴건지 선택
    @State var showUserProfile: Bool = false

    @State var cancelWriting: Bool = false // 작성 중인 댓글 취소하기
    @State var deleteWriting: Bool = false // 작성한 댓글 삭제하기

    @State var cancelEditing: Bool = false
    @State var confirmEditing: Bool = false

    @State var textRect = CGRect()

    // For Gesture
    @State var overDelete: Bool = false
    @State var dragging: Bool = false
    @State var pressing: Bool = false

    @FocusState var isFocused: Bool
    @State var keyboardUp: Bool = false

    @State var hideCommentModalVis: Bool = false

    @State var hideCommentTarget: Post.Comment?
    @State var delCommentTarget: Post.Comment?

    // 댓글 작성에 필요한 필드
    @State var content: String = ""
    @State var x: Double?
    @State var y: Double?

    @State var startingX: CGFloat?
    @State var startingY: CGFloat?

    // 댓글 편집에 필요한 필드
    @State var textSize: [String: CGSize] = [:]
    @State var draggingList: [String: Bool] = [:]
    @State var xList: [String: Double] = [:]
    @State var yList: [String: Double] = [:]

    @State var startingXList: [String: CGFloat] = [:]
    @State var startingYList: [String: CGFloat] = [:]

    @State var overHide: Bool = false

    var isMine: Bool // 해당 게시물이 내 게시물인지 남의 게시물인지

    // For API
    private let commentService: CommentService = .init()

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
                if !keyboardUp {
                    HStack(alignment: .center, spacing: 0) {
                        HStack(spacing: 5) {
                            if alreadyComment[postPageNum] == nil {
                                Image(isMine
                                    ? "sns-edit"
                                    : "sns-comment-empty")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 28, height: 28)

                                Text(
                                    isMine
                                        ? (isCommentEditing
                                            ? "편집중"
                                            : "편집하기")
                                        : "작성하기"
                                )
                                .font(.pretendard(size: 14, weight: .bold))

                            } else {
                                Image("sns-comment-fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)

                                Text("내 코멘트")
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .foregroundColor(Color(0x1DAFFF))
                            }
                        }
                        .onTapGesture {
                            if isMine {
                                withAnimation(.linear(duration: 0.1)) {
                                    isCommentEditing = true
                                }
                            } else if alreadyComment[postPageNum] == nil {
                                if post.user.isAllowFeedComment == 0
                                    || (post.user.isAllowFeedComment == 1 && post.user.friendStatus != 2)
                                {
                                    return
                                }
                                x = UIScreen.main.bounds.size.width / 2
                                y = UIScreen.main.bounds.size.width / 2
                                startingX = UIScreen.main.bounds.size.width / 2
                                startingY = UIScreen.main.bounds.size.width / 2

                                withAnimation(.linear(duration: 0.1)) {
                                    isCommentWriting = true
                                }

                                isFocused = true
                            } else {
                                delCommentTarget = alreadyComment[postPageNum]?.0
                                isCommentDeleting = true
                                deleteWriting = true
                            }
                        }
                        .foregroundColor(
                            isMine ?
                                isCommentEditing ? Color(0x1DAFFF) : Color(0x646464)
                                :
                                alreadyComment[postPageNum] == nil ? Color(0x646464) : Color(0x1DAFFF)
                        )
                        .opacity(isCommentWriting || isCommentDeleting ? 0 : 1)

                        Spacer(minLength: 0)

                        Group {
                            HStack(spacing: 10) {
                                if hideAllComment {
                                    Button {
                                        hideAllComment = false
                                    } label: {
                                        Image("todo-tag-hidden")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color(0x1CAFFF))
                                            .frame(width: 28, height: 28)
                                    }
                                } else {
                                    Button {
                                        hideAllComment = true
                                    } label: {
                                        Image("todo-tag-visible")
                                            .resizable()
                                            .renderingMode(.template)
                                            .foregroundColor(Color(0x646464))

                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }
                            .opacity(isCommentEditing || (isCommentWriting || isCommentDeleting) ? 0 : 1)
                        }
                    }
                    .overlay {
                        if isCommentEditing {
                            Group {
                                Button {
                                    cancelEditing = true
                                } label: {
                                    HStack(spacing: 5) {
                                        Image("sns-reset-button")
                                            .resizable()
                                            .frame(width: 28, height: 28)

                                        Text("초기화")
                                            .font(.pretendard(size: 14, weight: .bold))
                                            .foregroundColor(Color(0xFDFDFD))
                                    }
                                }
                            }
                        } else if !isCommentWriting && !isCommentDeleting {
                            Group {
                                HStack(spacing: 20) {
                                    Image("todo-toggle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .rotationEffect(Angle(degrees: -180))
                                        .onTapGesture {
                                            withAnimation {
                                                postPageNum -= 1
                                            }
                                        }
                                        .disabled(postPageNum == 0)

                                    Text("\(postPageNum + 1)/\(postImageList.count)")
                                        .font(.pretendard(size: 12, weight: .regular))
                                        .foregroundColor(Color(0xFDFDFD))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Color(0x646464))
                                        .cornerRadius(15)

                                    Image("todo-toggle")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .onTapGesture {
                                            withAnimation {
                                                postPageNum += 1
                                            }
                                        }
                                        .disabled(postPageNum == postImageList.count - 1)
                                }
                            }
                        }
                    }
                } else {
                    HStack {
                        Text(content == "" ? "댓글을 입력해주세요" : content)
                            .lineLimit(4)
                            .font(.pretendard(size: 14, weight: .bold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(0xFDFDFD))
                            .cornerRadius(9)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 20)
            .offset(y: -(deviceSize.width / 2 + 20))

            mainContent(deviceSize: deviceSize)
                .zIndex(3)

            if isMine, !isCommentEditing {
                HStack(spacing: 0) {
                    HStack(spacing: 5) {
                        Image("sns-heart-fill")
                        Text("\(post.likedCount)")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(Color(0x191919))
                    }
                    .padding(.trailing, 10)

                    HStack(spacing: 5) {
                        Image("sns-comment-fill")
                        Text("\(post.commentCount)")
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(Color(0x191919))
                    }

                    Spacer()

                    NavigationLink {
                        CommentListView(
                            commentVM: CommentViewModel(
                                userId: userId,
                                postImageIDList: postImageList.map { image in
                                    image.id
                                },
                                postId: postId,
                                imagePageNum: postPageNum
                            ),
                            isTemplate: isTemplate
                        )
                    } label: {
                        Image("slider")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 28, height: 28)
                            .foregroundColor(Color(0x646464))
                    }
                }
                .offset(y: deviceSize.width / 2 + 20)
                .padding(.horizontal, 20)
            }

            if hideCommentModalVis,
               let target = hideCommentTarget
            {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(4)
                    .onTapGesture {
                        withAnimation {
                            hideCommentModalVis = false
                            hideCommentTarget = nil
                        }
                    }

                Modal(isActive: $hideCommentModalVis,
                      ratio: UIScreen.main.bounds.height < 800 ? 0.35 : 0.3)
                {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            if let profileImage = target.user.profileImage {
                                ProfileImgView(imageUrl: URL(string: profileImage))
                                    .frame(width: 62, height: 62)
                            } else {
                                Image("sns-default-profile-image-rectangle")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 62, height: 62)
                            }

                            VStack(alignment: .leading, spacing: 0) {
                                Text(target.user.name)
                                    .font(.pretendard(size: 20, weight: .bold))
                                    .padding(.bottom, 4)

                                Text(target.createdAt.relative())
                                    .font(.pretendard(size: 14, weight: .regular))
                            }
                            .foregroundColor(Color(0x191919))
                            .padding(.leading, 20)
                        }
                        .padding(.bottom, 20)

                        Text("\(target.content)")
                            .font(.pretendard(size: 20, weight: .regular))
                            .foregroundColor(Color(0x646464))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)

                        Divider()
                            .padding(.vertical, 30)

                        Button {
                            updateCommentHide(target: target)
                        } label: {
                            Text("이 코멘트 숨기기")
                                .font(.pretendard(size: 20, weight: .regular))
                                .foregroundColor(Color(0x1DAFFF))
                        }
                    }
                    .padding(.top, 20)
                }
                .transition(.modal)
                .zIndex(5)
            }
        }
        .onAppear {
            fetchCommentList()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(isCommentEditing || isCommentDeleting || isCommentWriting ? Color(0x191919) : Color(0xFDFDFD))
        .edgesIgnoringSafeArea(.top)
        .ignoresSafeArea(.keyboard)
        .simultaneousGesture(
            TapGesture().onEnded {
                if isFocused {
                    isFocused = false
                }
            }
        )
        .onReceive(keyboardEventPublisher, perform: { value in
            withAnimation {
                keyboardUp = value
            }
        })
        .onChange(of: deleteWriting, perform: { value in
            if value == false {
                isCommentDeleting = false
            }
        })
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if isCommentWriting {
                        cancelWriting = true
                    } else if isCommentEditing {
                        cancelEditing = true
                    } else {
                        dismissAction.callAsFunction()
                    }
                } label: {
                    Image("back-button")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .foregroundColor(isCommentEditing || isCommentDeleting || isCommentWriting ? Color(0xFDFDFD) : Color(0x191919))
                }
            }

            ToolbarItem(placement: .principal) {
                Text(!isCommentWriting && !isCommentEditing && !isCommentDeleting ?
                    "코멘트" :
                    isCommentWriting ? "코멘트 작성" : isCommentEditing ? "코멘트 편집" : "코멘트 삭제")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(isCommentEditing || isCommentDeleting || isCommentWriting ? Color(0xFDFDFD) : Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if isCommentWriting || isCommentEditing {
                    Button {
                        if isCommentEditing {
                            confirmEditing = true
                        } else {
                            createComment()
                        }
                    } label: {
                        Image("confirm")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color(0xFDFDFD))
                    }.disabled(isCommentWriting && content == "")
                }
            }
        }
        .confirmationDialog("코멘트 작성을 취소할까요? 작성 중인 내용은 삭제됩니다.",
                            isPresented: $cancelWriting,
                            titleVisibility: .visible)
        {
            Button("삭제하기", role: .destructive) {
                content = ""
                isCommentWriting = false
            }
        }
        .confirmationDialog("코멘트를 삭제할까요? 이 작업은 복원할 수 없습니다.",
                            isPresented: $deleteWriting,
                            titleVisibility: .visible)
        {
            Button("삭제하기", role: .destructive) {
                // TODO: 댓글 삭제하는 api 연동
                deleteComment()
            }
        }
        .confirmationDialog("코멘트 편집을 취소할까요? 편집 중인 내용은 초기화됩니다.",
                            isPresented: $cancelEditing,
                            titleVisibility: .visible)
        {
            Button("편집 취소하기", role: .destructive) {
                clearEditing()
            }
        }
        .confirmationDialog("수정사항을 저장할까요?",
                            isPresented: $confirmEditing,
                            titleVisibility: .visible)
        {
            Button("저장 안함", role: .destructive) {
                clearEditing()
            }

            Button("저장 하기") {
                updateComment()
            }
        }
    }

    @ViewBuilder
    func mainContent(deviceSize: CGSize) -> some View {
        let sz = deviceSize.width
        let longPress = LongPressGesture(minimumDuration: 0.1)
            .onEnded { _ in
                withAnimation {
                    dragging = true
                    HapticManager.instance.impact(style: .heavy)
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

                x = value.location.x
                y = value.location.y

                // 범위 막기
                if value.location.y < 10 {
                    y = CGFloat(10) + textRect.height / 2
                }

                if value.location.x - textRect.width / 2 <= 10 {
                    x = textRect.width / 2 + CGFloat(10)
                }

                if value.location.x + textRect.width / 2 >= sz - 10 {
                    x = CGFloat(sz - 10) - textRect.width / 2
                }
            }
            .onEnded { value in
                if overDelete {
                    if !isMine {
                        if alreadyComment[postPageNum] != nil {
                            deleteWriting = true
                        } else {
                            cancelWriting = true
                        }
                    }
                    overDelete = false
                }

                if value.location.y + textRect.height / 2 >= sz - 10 {
                    y = CGFloat(sz - 10) - textRect.height / 2
                }

                withAnimation {
                    dragging = false
                }
            }

        let combined = longPress.sequenced(before: drag)

        GeometryReader { _ in
            ZStack {
                if isCommentWriting {
                    Color.black.opacity(0.3)
                        .zIndex(3)
                }

                postListView()
                    .zIndex(1)

                commentListView()

                Group {
                    if isCommentWriting {
                        if overDelete {
                            Image("sns-drag-cancel")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .zIndex(5)
                        } else {
                            Image("sns-drag-cancel-default")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .zIndex(5)
                        }
                    } else if isCommentEditing {
                        if overHide {
                            Image("sns-drag-hide")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .zIndex(5)
                        } else {
                            Image("sns-drag-hide-default")
                                .resizable()
                                .frame(width: 90, height: 90)
                                .zIndex(5)
                        }
                    }
                }
                .offset(y: deviceSize.width / 2 + 80)
            }
            .onTapGesture(count: 2) {}
            .onTapGesture { _ in
                // 이미지 영역 눌렀을 때 생성, 삭제, 수정 플로우 시작
                if post.user.isAllowFeedComment == 0
                    || (post.user.isAllowFeedComment == 1 &&
                        post.user.friendStatus != 2)
                {
                    return
                }

                if isCommentWriting || isCommentDeleting || isCommentEditing {
                    return
                }

                if isMine {
                    showUserProfile.toggle()
                    return
                }

                // 기존에 댓글을 작성했는지 처음 작성인지 판별
                if let comment = alreadyComment[postPageNum] { // 기존 댓글이 있는 경우
                    delCommentTarget = comment.0
                    isCommentDeleting = true
                    deleteWriting = true
                } else {
                    x = deviceSize.width / 2
                    y = deviceSize.width / 2
                    startingX = deviceSize.width / 2
                    startingY = deviceSize.width / 2
                    withAnimation(.linear(duration: 0.1)) {
                        isCommentWriting = true
                    }
                    isFocused = true
                }
            }

            if isCommentWriting, let x, let y {
                TextFieldDynamicWidth(title: "        ", text: $content, textRect: $textRect) { _ in
                    // logic
                } onCommit: {
                    // logic
                }
                .lineLimit(4)
                .focused($isFocused)
                .font(.pretendard(size: overDelete ? 11 : 14, weight: .bold))
                .foregroundColor(Color(0x1DAFFF))
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
                .onChange(of: content) { value in
                    if value.count > 25 {
                        content = String(
                            value[
                                value.startIndex ..< value.index(value.endIndex, offsetBy: -1)
                            ]
                        )
                    }

                    if value.last == "\n" {
                        content = String(
                            value[
                                value.startIndex ..< value.index(value.endIndex, offsetBy: -1)
                            ]
                        )
                        isFocused = false
                    }
                }
            }
        }
        .frame(
            width: deviceSize.width,
            height: deviceSize.width
        )
    }

    @ViewBuilder
    func commentListView() -> some View {
        let sz = deviceSize.width
        if !hideAllComment {
            ForEach(commentList[postPageNum]) { comment in
                let longPress = LongPressGesture(minimumDuration: 0.1)
                    .onEnded { _ in
                        startingXList[comment.id] = CGFloat(comment.x)
                        startingYList[comment.id] = CGFloat(comment.y)
                        withAnimation {
                            draggingList[comment.id] = true
                            HapticManager.instance.impact(style: .heavy)
                        }
                    }

                let drag = DragGesture()
                    .onChanged { value in
                        // 숨김 버튼 근처인 경우
                        if value.location.x >= sz / 2 - 45,
                           value.location.x <= sz / 2 + 45,
                           value.location.y >= sz + 25,
                           value.location.y <= sz + 120
                        {
                            hideCommentTarget = comment
                            overHide = true
                        } else {
                            hideCommentTarget = nil
                            overHide = false
                        }

                        xList[comment.id] = value.location.x
                        yList[comment.id] = value.location.y

                        // 범위
                        if value.location.y < 10 {
                            yList[comment.id] = CGFloat(10) + ((textSize[comment.id]?.height ?? 0) / 2)
                        }

                        if value.location.x - ((textSize[comment.id]?.width ?? 0) / 2) <= 10 {
                            xList[comment.id] = CGFloat(10) + ((textSize[comment.id]?.width ?? 0) / 2)
                        }

                        if value.location.x + ((textSize[comment.id]?.width ?? 0) / 2) >= sz - 10 {
                            xList[comment.id] = CGFloat(sz - 10) - ((textSize[comment.id]?.width ?? 0) / 2)
                        }
                    }
                    .onEnded { value in
                        if overHide {
                            hideCommentTarget = comment
                            hideCommentModalVis = true
                            overHide = false
                        }

                        if value.location.y + ((textSize[comment.id]?.height ?? 0) / 2) >= sz - 10 {
                            yList[comment.id] = CGFloat(sz - 10) - ((textSize[comment.id]?.height ?? 0) / 2)
                        }
                        withAnimation {
                            draggingList[comment.id] = false
                        }
                    }

                let combined = longPress.sequenced(before: drag)

                Text("\(comment.content)")
                    .font(.pretendard(
                        size: hideCommentTarget?.id == comment.id && overHide ? 11 : 14,
                        weight: hideCommentTarget?.id == comment.id && overHide ? .bold : .regular
                    ))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(0xFDFDFD))
                    .cornerRadius(9)
                    .background(ViewGeometry())
                    .onPreferenceChange(ViewSizeKey.self) {
                        textSize[comment.id] = $0
                    }
                    .position(
                        x: isCommentEditing ? (xList[comment.id] ?? comment.x)! : comment.x,
                        y: isCommentEditing ? (yList[comment.id] ?? comment.y)! : comment.y
                    )
                    .foregroundColor(
                        isCommentDeleting && alreadyComment[postPageNum]?.0.id == comment.id ?
                            Color(0x1DAFFF) :
                            hideCommentTarget?.id == comment.id ? Color(0x1DAFFF) : Color(0x191919)
                    )
                    .zIndex(6)
                    .overlay {
                        if isMine, showUserProfile, !isCommentEditing {
                            userProfileInfoView(comment: comment)
                                .position(x: CGFloat(comment.x), y: CGFloat(comment.y))
                                .offset(
                                    y: comment.y > 50 ? -35 : 35
                                )
                                .zIndex(5)
                        }
                    }
                    .simultaneousGesture(
                        isCommentEditing ? combined : nil
                    )
            }
        }
    }

    @ViewBuilder
    func postListView() -> some View {
        TabView(selection: $postPageNum) {
            ForEach(imageUrlList.indices, id: \.self) { idx in
                ZStack {
                    if isTemplate, let templateContent {
                        Text("\(templateContent)")
                            .lineLimit(nil)
                            .font(.pretendard(size: 24, weight: .bold))
                            .foregroundColor(Color(contentColor))
                            .padding(.all, 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .zIndex(99)
                    }

                    if let url = imageUrlList[idx] {
                        if !isCommentWriting,
                           !isCommentDeleting,
                           !isCommentEditing,
                           !isTemplate
                        {
                            GeometryReader { proxy in
                                KFImage(url)
                                    .downsampling(
                                        size: CGSize(
                                            width: deviceSize.width * UIScreen.main.scale,
                                            height: deviceSize.width * UIScreen.main.scale
                                        )
                                    )
                                    .placeholder { _ in
                                        ProgressView()
                                    }
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(
                                        width: deviceSize.width,
                                        height: deviceSize.width
                                    )
                                    .clipShape(Rectangle())
                                    .modifier(
                                        ImageModifier(
                                            contentSize: CGSize(
                                                width: proxy.size.width,
                                                height: proxy.size.height
                                            )
                                        )
                                    )
                            }
                        } else {
                            KFImage(url)
                                .downsampling(
                                    size: CGSize(
                                        width: deviceSize.width * UIScreen.main.scale,
                                        height: deviceSize.width * UIScreen.main.scale
                                    )
                                )
                                .renderingMode(.original)
                                .resizable()
                                .frame(
                                    width: deviceSize.width,
                                    height: deviceSize.width
                                )
                                .clipShape(Rectangle())
                        }
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .overlay {
            if isCommentEditing {
                Rectangle()
                    .fill(Color(0x191919).opacity(0.5))
            }
        }
        .onChange(of: postPageNum, perform: { _ in
            xList = [:]
            yList = [:]
            startingXList = [:]
            startingYList = [:]
            draggingList = [:]
            content = ""
            x = nil
            y = nil
            startingX = nil
            startingY = nil
        })
        .background(Color(0xFDFDFD))
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    @ViewBuilder
    func userProfileInfoView(comment: Post.Comment) -> some View {
        HStack(spacing: 0) {
            ProfileImgView(imageUrl: URL(string: comment.user.profileImage ?? "unknown"))
                .frame(width: 18, height: 18)
                .padding(.trailing, 8)

            Text("\(comment.user.name)")
                .font(.pretendard(size: 16, weight: .bold))
                .foregroundColor(Color(0x191919))

            Image("todo-toggle")
                .renderingMode(.template)
                .frame(width: 20, height: 20)
                .foregroundColor(Color(0x646464))
        }
        .onTapGesture {
            hideCommentTarget = comment
            hideCommentModalVis = true
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(0xFDFDFD).opacity(0.5))
        .cornerRadius(10)
    }

    func fetchCommentList() {
        for (idx, postImage) in postImageList.enumerated() {
            commentService.fetchImageComment(
                targetPostId: postId,
                targetPostImageId: postImage.id
            ) { result in
                switch result {
                case .success(let success):
                    self.commentList[idx] = success.compactMap {
                        Post.Comment(id: $0.id, user: $0.user, content: $0.content, x: $0.x / 100 * deviceSize.width, y: $0.y / 100 * deviceSize.width, createdAt: $0.createdAt)
                    }
                case .failure(let failure):
                    print("[Debug] \(failure)")
                    print("\(#file) \(#function)")
                    self.commentList[idx] = postImage.comments.compactMap {
                        Post.Comment(id: $0.id, user: $0.user, content: $0.content, x: $0.x / 100 * deviceSize.width, y: $0.y / 100 * deviceSize.width, createdAt: $0.createdAt)
                    }
                }
            }
        }
    }

    func createComment() {
        if !isTemplate {
            commentService.createComment(
                targetPostId: postId,
                targetPostImageId: postImageList[postPageNum].id,
                comment: Request.Comment(content: content, x: x, y: y)
            ) { result in
                switch result {
                case .success:
                    content = ""
                    x = nil
                    y = nil
                    isCommentWriting = false
                    fetchCommentList()

                    post.isCommented = true
                case .failure(let error):
                    switch error {
                    case CommentService.CommentError.badword:
                        Global.shared.toastMessageTheme = .light
                        Global.shared.toastMessageContent = "댓글에 부적절한 단어가 포함되어 있습니다."
                        withAnimation {
                            Global.shared.showToastMessage = true
                        }
                    default:
                        break
                    }
                }
            }
        } else {
            commentService.createCommentTemplate(
                targetPostId: postId,
                comment: Request.Comment(content: content, x: x, y: y)
            ) { result in
                switch result {
                case .success:
                    content = ""
                    x = nil
                    y = nil
                    isCommentWriting = false

                    fetchCommentList()
                    post.isCommented = true
                case .failure(let error):
                    switch error {
                    case CommentService.CommentError.badword:
                        Global.shared.toastMessageTheme = .light
                        Global.shared.toastMessageContent = "댓글에 부적절한 단어가 포함되어 있습니다."
                        withAnimation {
                            Global.shared.showToastMessage = true
                        }
                    default:
                        break
                    }
                }
            }
        }
    }

    func updateComment() {
        let targetCommentIdList = Array(xList.keys)
        var xList_ = [Double]()
        var yList_ = [Double]()
        for key in targetCommentIdList {
            let x = (xList[key] ?? 190) / UIScreen.main.bounds.size.width * 100
            let y = (yList[key] ?? 190) / UIScreen.main.bounds.size.width * 100
            xList_.append(x)
            yList_.append(y)
        }

        commentService.updateCommentList(
            targetPostId: postId,
            targetCommentIdList: targetCommentIdList,
            xList: xList_,
            yList: yList_
        ) { result in
            switch result {
            case .success:
                xList = [:]
                yList = [:]
                startingXList = [:]
                startingYList = [:]
                draggingList = [:]
                isCommentEditing = false

                fetchCommentList()
            case .failure:
                print("실패!")
            }
        }
    }

    func updateCommentHide(target: Post.Comment) {
        let request = Request.Comment(isPublic: false)

        commentService.updateComment(
            targetUserId: target.user.id,
            targetCommentId: target.id,
            comment: request
        ) { result in
            switch result {
            case .success:
                fetchCommentList()
                hideCommentModalVis = false
                hideCommentTarget = nil
            case .failure(let failure):
                print("[Debug] \(failure) \(#fileID) \(#function)")
            }
        }
    }

    func deleteComment() {
        if let target = delCommentTarget {
            commentService.deleteComment(
                targetUserId: target.user.id,
                targetCommentId: target.id
            ) { result in
                switch result {
                case .success:
                    fetchCommentList()
                    post.isCommented = false
                case .failure(let failure):
                    print("[Debug] \(failure)")
                }
            }
        }
    }

    func clearEditing() {
        xList = [:]
        yList = [:]
        startingXList = [:]
        startingYList = [:]
        draggingList = [:]
        isCommentEditing = false
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}
