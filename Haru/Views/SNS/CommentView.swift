//
//  CommentView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/12.
//

import SwiftUI

struct CommentView: View {
    @Environment(\.dismiss) var dismissAction

    var postImageList: [Post.Image]
    var commentList: [[Post.Comment]] {
        var result = Array(repeating: [Post.Comment](), count: postImageList.count)
        for (idx, image) in postImageList.enumerated() {
            result[idx].append(contentsOf: image.comments)
        }
        return result
    }

    @State var postPageNum: Int = 0

    @State var isCommentCreate: Bool = false

    // For Gesture
    @State var overDelete: Bool = false
    @State var dragStart: Bool = false

    @State var delCommentModalVis: Bool = false
    @State var delCommentTarget: Post.Comment?

    // 댓글 작성에 필요한 필드
    @State var content: String = ""
    @State var x: CGFloat = 100
    @State var y: CGFloat = 100

    @State var startingX: CGFloat?
    @State var startingY: CGFloat?

    var isMine: Bool

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        ZStack {
            Text("\(postPageNum + 1)/\(postImageList.count)")
                .font(.pretendard(size: 14, weight: .bold))
                .foregroundColor(Color(0xFDFDFD))
                .offset(y: -250)

            mainContent(deviceSize: deviceSize)
                .zIndex(3)

            if isCommentCreate {
                ZStack {
                    Circle()
                        .frame(width: overDelete ? 90 : 77, height: overDelete ? 90 : 77)
                        .foregroundColor(overDelete ? Color(0xF71E58) : .gray2)

                    Image("cancel")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 38, height: 38)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .zIndex(2)
            }

            if delCommentModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
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
                                    print("확인")
                                    delCommentModalVis = false
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
                .zIndex(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(0x191919))
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
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
                Button {} label: {
                    Image("confirm")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(0xFDFDFD))
                }
            }
        }
    }

    @ViewBuilder
    func mainContent(deviceSize: CGSize) -> some View {
        let longPress = LongPressGesture(minimumDuration: 0.3)
            .onEnded { longPress in
                withAnimation {
                    dragStart = true
                }
            }

        let drag = DragGesture()
            .onChanged { value in
                if value.location.y < 0 {
                    return
                }
                x = value.location.x
                y = value.location.y
            }
            .onEnded { value in
                if value.location.y > 380 {
                    x = startingX ?? 190
                    y = startingY ?? 190
                    return
                }
                withAnimation {
                    dragStart = false
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
            }
            .onTapGesture { location in
                if isMine || isCommentCreate {
                    return
                }
                isCommentCreate = true
                x = location.x
                y = location.y
                startingX = location.x
                startingY = location.y
            }

            if isCommentCreate {
                TextFieldDynamicWidth(title: "        ", text: $content) { editingChange in
                    // logic
                } onCommit: {
                    // logic
                }
                .font(.pretendard(size: 14, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(0xFDFDFD))
                .cornerRadius(9)
                .scaleEffect(dragStart ? 1.5 : 1)
                .position(x: x, y: y)
                .zIndex(4)
                .gesture(combined)
            }
        }
        .frame(
            width: deviceSize.width > 395 ? 395 : deviceSize.width,
            height: deviceSize.width > 395 ? 395 : deviceSize.width
        )
    }

    @ViewBuilder
    func commentListView() -> some View {
        ForEach(commentList[postPageNum]) { comment in
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

    @ViewBuilder
    func postListView() -> some View {
        TabView(selection: $postPageNum) {
            ForEach(postImageList.indices, id: \.self) { idx in
                AsyncImage(url: URL(string: postImageList[idx].url)) { image in
                    image
                        .resizable()
                } placeholder: {
                    Image(systemName: "wifi.slash")
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(
            postImageList: [
                Post.Image(id: UUID().uuidString, originalName: "test.png", url: "https://blog.kakaocdn.net/dn/0mySg/btqCUccOGVk/nQ68nZiNKoIEGNJkooELF1/img.jpg", mimeType: "image/png", comments: [
                    Post.Comment(id: UUID().uuidString, user: Post.User(id: UUID().uuidString, name: "테스터1"), content: "안녕하세요", x: 250, y: 250, createdAt: Date()),

                    Post.Comment(id: UUID().uuidString, user: Post.User(id: UUID().uuidString, name: "테스터2"), content: "안녕하세요", x: 380, y: 250, createdAt: Date()),
                ]),

                Post.Image(id: UUID().uuidString, originalName: "test.png", url: "https://blog.kakaocdn.net/dn/bezjux/btqCX8fuOPX/6uq138en4osoKRq9rtbEG0/img.jpg", mimeType: "image/png", comments: []),
            ],
            isMine: false
        )
    }
}
