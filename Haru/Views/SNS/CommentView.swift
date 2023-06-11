//
//  CommentView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import SwiftUI

struct CommentView: View, KeyboardReadable {
    @Environment(\.dismiss) var dismissAction
    let deviceSize = UIScreen.main.bounds.size

    @Binding var commentModify: Bool

    var isTemplate: Bool = false
    var templateContent: String?
    var contentColor: String?

    var postId: String
    var userId: String // 게시물을 작성한 사용자 id
    @State var postImageList: [Post.Image]
    var imageList: [PostImage?]
    var commentList: [[Post.Comment]] { // [pageNum][commentIdx]
        // TODO: 민재형이 서버에서 포스트의 이미지별 댓글 api 나오면 수정해주기

        var result = Array(repeating: [Post.Comment](), count: postImageList.count)
        for (idx, image) in postImageList.enumerated() {
            result[idx].append(contentsOf: image.comments.compactMap {
                Post.Comment(id: $0.id, user: $0.user, content: $0.content, x: $0.x / 100 * deviceSize.width, y: $0.y / 100 * deviceSize.width, createdAt: $0.createdAt)
            })
        }
        return result
    }

    @State var postPageNum: Int = 0

    // 내가 이미 작성한 댓글이 있으면
    // alreadyComment[postPageNum] = (Post.Comment, Int)
    // 없으면 nil
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

    @State var isCommentWriting: Bool = false // 댓글을 작성 중인가
    @State var isCommentDeleting: Bool = false // 댓글을 삭제 중인가 (자신이 작성한 댓글)
    @State var isCommentEditing: Bool = false // 댓글을 수정 중인가 (본인 게시물에서만 가능)
    @State var hideAllComment: Bool = false // 댓글을 가릴건지 안가릴건지 선택
    @State var showUserProfile: Bool = false

    @State var cancelWriting: Bool = false // 작성 중인 댓글 취소하기
    @State var deleteWriting: Bool = false // 작성한 댓글 삭제하기

    @State var cancelEditing: Bool = false

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
                HStack(alignment: .center, spacing: 0) {
                    HStack(spacing: 5) {
                        Image(isMine ? "sns-edit" : "sns-comment-empty")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 28, height: 28)

                        if alreadyComment[postPageNum] == nil {
                            Text(
                                isMine ?
                                    isCommentEditing ? "편집중" : "편집하기"
                                    :
                                    "작성하기"
                            )
                            .font(.pretendard(size: 14, weight: .bold))
                        }
                    }
                    .onTapGesture {
                        if isMine {
                            isCommentEditing = true
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
                                    Image("sns-comment-disable")
                                        .resizable()
                                        .renderingMode(.template)
                                        .foregroundColor(Color(0xCACACA))
                                        .frame(width: 28, height: 28)
                                }
                            } else {
                                Button {
                                    hideAllComment = true
                                } label: {
                                    Image("sns-comment")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0x1CAFFF))
                                }
                            }

                            if isMine {
                                NavigationLink {
                                    CommentListView(
                                        commentVM: CommentViewModel(
                                            userId: userId,
                                            postImageIDList: postImageList.map { image in
                                                image.id
                                            },
                                            postId: postId,
                                            imagePageNum: postPageNum
                                        )
                                    )
                                } label: {
                                    Image("slider")
                                        .resizable()
                                        .renderingMode(.template)
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0x646464))
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
                                    Image("comment-reset")
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

                if keyboardUp {
                    Text(content == "" ? "댓글을 입력해주세요" : content)
                        .lineLimit(4)
                        .font(.pretendard(size: 14, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(0xFDFDFD))
                        .cornerRadius(9)
                }
            }
            .padding(.horizontal, 20)
            .offset(y: -230)

            mainContent(deviceSize: deviceSize)
                .zIndex(3)

            if hideCommentModalVis,
               let target = hideCommentTarget
            {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(4)
                    .onTapGesture {
                        withAnimation {
                            hideCommentModalVis = false
                        }
                    }

                Modal(isActive: $hideCommentModalVis, ratio: 0.3) {
                    VStack(spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            if let profileImage = target.user.profileImage {
                                ProfileImgView(imageUrl: URL(string: profileImage))
                                    .frame(width: 62, height: 62)
                            } else {
                                Image("background-main-splash")
                                    .resizable()
                                    .clipShape(Circle())
                                    .frame(width: 62, height: 62)
                            }

                            Text(target.user.name)
                                .font(.pretendard(size: 20, weight: .bold))
                                .foregroundColor(Color(0x191919))
                                .padding(.leading, 20)
                        }
                        .padding(.bottom, 20)

                        Text("\(target.content)")
                            .font(.pretendard(size: 20, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Divider()
                            .padding(.vertical, 30)

                        Button {
                            print("이 코멘트 숨기기 api 연동")
                            // TODO: completion에 넣어주기
                            hideCommentModalVis = false
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
                        if isCommentWriting {
                            createComment()
                        } else {
                            updateComment()
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
                if let target = delCommentTarget {
                    commentService.deleteComment(
                        targetUserId: target.user.id,
                        targetCommentId: target.id
                    ) { result in
                        switch result {
                        case .success(let success):
                            if success {
                                postImageList[postPageNum].comments = postImageList[postPageNum].comments.filter {
                                    $0.id != delCommentTarget?.id
                                }
                            }
                        case .failure(let failure):
                            print("[Debug] \(failure)")
                        }
                    }
                }
            }
        }
        .confirmationDialog("코멘트 편집을 취소할까요? 편집 중인 내용은 초기화됩니다.",
                            isPresented: $cancelEditing,
                            titleVisibility: .visible)
        {
            Button("편집 취소하기", role: .destructive) {
                xList = [:]
                yList = [:]
                startingXList = [:]
                startingYList = [:]
                draggingList = [:]
                isCommentEditing = false
            }
        }
    }

    @ViewBuilder
    func mainContent(deviceSize: CGSize) -> some View {
        let sz = deviceSize.width
        let longPress = LongPressGesture(minimumDuration: 0.15)
            .onEnded { _ in
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
                    if !isMine {
                        if alreadyComment[postPageNum] != nil {
                            deleteWriting = true
                        } else {
                            cancelWriting = true
                        }
                    } else {
                        // TODO: 게시물 작성자가 남의 댓글 삭제할 수 있게
                    }

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

        GeometryReader { _ in
            ZStack {
                if isCommentWriting {
                    Color.black.opacity(0.3)
                        .zIndex(3)
                }

                postListView()
                    .zIndex(1)

                commentListView()

                if isCommentWriting {
                    ZStack {
                        Circle()
                            .frame(width: overDelete ? 90 : 80, height: overDelete ? 90 : 80)
                            .foregroundColor(overDelete ? Color(0xF71E58) : .gray2)

                        if alreadyComment[postPageNum] == nil {
                            Image("cancel")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 38, height: 38)
                                .foregroundColor(.white)
                        } else {
                            Image("trash")
                                .resizable()
                                .renderingMode(.template)
                                .frame(width: 38, height: 38)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .offset(y: 80 + 30)
                    .zIndex(2)
                }
            }
            .onTapGesture { location in
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
                    x = location.x
                    y = location.y
                    startingX = location.x
                    startingY = location.y
                    isCommentWriting = true
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
                .font(.pretendard(size: dragging ? overDelete ? 11 : 18 : 14, weight: .bold))
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
                let longPress = LongPressGesture(minimumDuration: 0.15)
                    .onEnded { _ in
                        startingXList[comment.id] = CGFloat(comment.x)
                        startingYList[comment.id] = CGFloat(comment.y)
                        withAnimation {
                            draggingList[comment.id] = true
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
                            overHide = true
                        } else {
                            overHide = false
                        }

                        // 범위 막기
                        if value.location.y < 0 {
                            return
                        }

                        if value.location.x + ((textSize[comment.id]?.width ?? 0) / 2) >= sz - 10 ||
                            value.location.x - ((textSize[comment.id]?.width ?? 0) / 2) <= 10 ||
                            value.location.y - ((textSize[comment.id]?.height ?? 0) / 2) <= 10
                        {
                            return
                        } else {
                            xList[comment.id] = value.location.x
                            yList[comment.id] = value.location.y
                        }
                    }
                    .onEnded { value in
                        if overHide {
                            print("\(comment.content)를 숨기기")
                            // TODO: 댓글 숨기기 API 연동
                            overHide = false
                        }

                        if value.location.y + (textSize[comment.id]?.height ?? 0 / 2) > sz - 5 {
                            xList[comment.id] = startingXList[comment.id] ?? 190
                            yList[comment.id] = startingYList[comment.id] ?? 190
                        }
                        withAnimation {
                            draggingList[comment.id] = false
                        }
                    }

                let combined = longPress.sequenced(before: drag)

                Text("\(comment.content)")
                    .font(.pretendard(size: 14, weight: .regular))
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
                            Color(0x1AFFF) : Color(0x191919)
                    )
                    .zIndex(2)
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
            ForEach(imageList.indices, id: \.self) { idx in
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

                    if let uiImage = imageList[idx]?.uiImage {
                        Image(uiImage: uiImage)
                            .resizable()
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

    func createComment() {
        if !isTemplate {
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
                    isCommentWriting = false

                    // TODO: 게시물 댓글 다시 불러오기
                    postImageList[postPageNum].comments.append(success)
                    commentModify = true
                case .failure(let failure):
                    print("[Debug] \(failure)")
                    print("\(#fileID) \(#function)")
                }
            }
        } else {
            commentService.createCommentTemplate(
                targetPostId: postId,
                comment: Request.Comment(content: content, x: x, y: y)
            ) { result in
                switch result {
                case .success(let success):
                    content = ""
                    x = nil
                    y = nil
                    isCommentWriting = false

                    // TODO: 게시물 댓글 다시 불러오기
                    postImageList[postPageNum].comments.append(success)
                    commentModify = true
                case .failure(let failure):
                    print("[Debug] \(failure)")
                    print("\(#fileID) \(#function)")
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
                // TODO: 게시물 이미지 댓글 다시 불러오기
                xList = [:]
                yList = [:]
                startingXList = [:]
                startingYList = [:]
                draggingList = [:]
                isCommentEditing = false

                // TODO: 게시물 댓글 다시 불러오기
                commentModify = true
            case .failure:
                print("실패!")
            }
        }
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
