//
//  CommentListView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/29.
//

import SwiftUI

struct CommentListView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var commentVM: CommentViewModel

    @State private var commentAlert: Bool = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                Divider()
                    .foregroundColor(Color(0xdbdbdb))
                HStack(alignment: .center, spacing: 0) {
                    Group {
                        HStack(spacing: 5) {
                            Image("sns-edit")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)

                            Text("편집하기")
                                .font(.pretendard(size: 14, weight: .bold))
                        }
                        .foregroundColor(Color(0x646464))
                    }

                    Spacer(minLength: 0)

                    Image("sns-comment-fill")
                        .overlay(content: {
                            Text("\(commentVM.commentTotalCount[commentVM.postImageIDList[commentVM.imagePageNum]] ?? 0)")
                                .font(.pretendard(size: 14, weight: .bold))
                                .foregroundColor(Color(0x646464))
                                .offset(x: 30)
                        })
                        .padding(.trailing, 38)
                }
                .overlay(content: {
                    Group {
                        HStack(spacing: 20) {
                            Image("todo-toggle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .rotationEffect(Angle(degrees: -180))
                                .onTapGesture {
                                    withAnimation {
                                        commentVM.imagePageNum -= 1
                                    }
                                }
                                .disabled(commentVM.imagePageNum == 0)

                            Text("\(commentVM.imagePageNum + 1)/\(commentVM.postImageIDList.count)")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xfdfdfd))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(Color(0xdbdbdb))
                                .cornerRadius(15)

                            Image("todo-toggle")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    withAnimation {
                                        commentVM.imagePageNum += 1
                                    }
                                }
                                .disabled(commentVM.imagePageNum == commentVM.postImageIDList.count - 1)
                        }
                    }
                })
                .padding(.top, 10)
                .padding(.horizontal, 20)

                if let commentList = commentVM.imageCommentList[commentVM.postImageIDList[commentVM.imagePageNum]] {
                    ForEach(commentList.indices, id: \.self) { idx in
                        let comment = commentList[idx]
                        HStack(spacing: 0) {
                            ProfileImgView(
                                profileImage: commentVM.imageCommentUserProfileList[commentVM.postImageIDList[commentVM.imagePageNum]]?[idx])
                                .frame(width: 40, height: 40)
                                .padding(.trailing, 14)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 10) {
                                    Text(comment.user.name)
                                        .font(.pretendard(size: 14, weight: .bold))
                                        .foregroundColor(Color(0x191919))

                                    Text("\(comment.createdAt.relative())")
                                        .font(.pretendard(size: 10, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                }

                                Text(comment.content)
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(
                                        comment.isPublic ?
                                            Color(0x646464) : Color(0xdbdbdb)
                                    )
                            }

                            Spacer()

                            Button {
                                commentVM.updateCommentPublic(
                                    userId: comment.user.id,
                                    commentId: comment.id,
                                    isPublic: !comment.isPublic,
                                    imageId: commentVM.postImageIDList[commentVM.imagePageNum],
                                    idx: idx
                                )
                            } label: {
                                Image(comment.isPublic ?
                                    "sns-comment" : "sns-comment-disable")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 10)
                                    .foregroundColor(comment.isPublic ?
                                        Color(0x1dafff) : Color(0xdbdbdb)
                                    )
                            }

                            Button {
                                commentAlert = true
                            } label: {
                                Image("more")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 28, height: 28)
                                    .foregroundColor(Color(0x646464))
                            }
                            .confirmationDialog("", isPresented: $commentAlert) {
                                Button("이 코멘트 삭제하기", role: .destructive) {
                                    commentVM.deleteComment(
                                        userId: comment.user.id,
                                        commentId: comment.id,
                                        imageId: commentVM.postImageIDList[commentVM.imagePageNum]
                                    )
                                }

                                Button("이 코멘트 신고하기") {
                                    print("코멘트 신고하기")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    }

                    if !commentList.isEmpty, commentVM.page <= commentVM.commentTotalPage[commentVM.postImageIDList[commentVM.imagePageNum]] ?? 0 {
                        HStack {
                            Spacer()
                            ProgressView()
                                .onAppear {
                                    print("더 불러오기")
                                    commentVM.loadMoreComments()
                                }
                            Spacer()
                        }
                    }
                } else {
                    Text("작성된 댓글이 아직 없습니다.")
                        .padding(.top, 20)
                }
            }
        }
        .animation(.none)
        .onAppear {
            commentVM.loadMoreComments()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color(0x191919))
                }
            }

            ToolbarItem(placement: .principal) {
                Text("코멘트 리스트")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }
        }
    }
}
