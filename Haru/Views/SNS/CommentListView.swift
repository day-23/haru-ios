//
//  CommentListView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/29.
//

import SwiftUI

struct CommentListView: View {
    var postImageIDList: [Post.Image.ID]
    var postCommentList: [Post.Image.ID: [Post.Comment]]
    @State var postPageNum: Int = 0

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Divider()
                HStack(alignment: .center, spacing: 0) {
                    Group {
                        HStack(spacing: 5) {
                            Image("touch-edit")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)

                            Text("편집하기")
                                .font(.pretendard(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(0x646464))
                    }

                    Spacer(minLength: 0)

                    Group {
                        HStack(spacing: 20) {
                            Image("toggle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .rotationEffect(Angle(degrees: -180))
                                .onTapGesture {
                                    withAnimation {
                                        postPageNum -= 1
                                    }
                                }
                                .disabled(postPageNum == 0)

                            Text("\(postPageNum + 1)/\(postCommentList.count)")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xfdfdfd))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color(0xdbdbdb))
                                .cornerRadius(15)

                            Image("toggle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    withAnimation {
                                        postPageNum += 1
                                    }
                                }
                                .disabled(postPageNum == postCommentList.count - 1)
                        }
                    }

                    Spacer(minLength: 0)

                    Group {
                        HStack(spacing: 10) {
                            Image("chat-bubble-fill")

                            Text("\(postCommentList[postImageIDList[postPageNum]]?.count ?? 0)")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(Color(0x646464))
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 20)
                .padding(.trailing, 15)

                if let commentList = postCommentList[postImageIDList[postPageNum]] {
                    ForEach(commentList, id: \.id) { comment in
                        HStack(spacing: 0) {
                            Circle()
                                .foregroundColor(Color(0x191919))
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 14)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 10) {
                                    Text(comment.user.name)
                                        .font(.pretendard(size: 14, weight: .bold))
                                        .foregroundColor(Color(0x191919))

                                    Text("\(comment.createdAt.minute)분 전")
                                        .font(.pretendard(size: 10, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                }

                                Text(comment.content)
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(Color(0x646464))
                            }

                            Spacer()

                            Image("comment-bubble")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding(.trailing, 10)

                            Image("ellipsis")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }
                } else {
                    Text("작성된 댓글이 아직 없습니다.")
                        .padding(.top, 20)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("뒤로 가기")
                } label: {
                    Image("back-button")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(0xfdfdfd))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("코멘트 리스트")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0xfdfdfd))
            }
        }
    }
}

struct CommentListView_Previews: PreviewProvider {
    static let imageID = UUID().uuidString
    static var previews: some View {
        CommentListView(
            postImageIDList: [imageID],
            postCommentList: [
                imageID:
                    [
                        Post.Comment(
                            id: UUID().uuidString,
                            user: Post.User(id: UUID().uuidString, name: "테스터1"),
                            content: "hi",
                            x: 10,
                            y: 10,
                            createdAt: Date()
                        ),

                        Post.Comment(
                            id: UUID().uuidString,
                            user: Post.User(id: UUID().uuidString, name: "테스터2"),
                            content: "bye",
                            x: 10,
                            y: 10,
                            createdAt: Date()
                        ),

                        Post.Comment(
                            id: UUID().uuidString,
                            user: Post.User(id: UUID().uuidString, name: "테스터3"),
                            content: "world",
                            x: 10,
                            y: 10,
                            createdAt: Date()
                        ),
                    ],
            ]
        )
    }
}
