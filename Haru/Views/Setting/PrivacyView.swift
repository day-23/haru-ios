//
//  PrivacyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct PrivacyView: View {
    @Environment(\.dismiss) var dismissAction
    @ObservedObject var privacyViewModel: PrivacyViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "개인정보 보호") {
                self.dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)
                .padding(.bottom, 20)

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("계정 공개")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("계정을 비공개로 설정")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x646464))
                            .padding(.trailing, 10)

                        Image("setting-privacy-lock")
                            .resizable()
                            .frame(width: 20, height: 20)

                        Spacer()

                        Toggle(
                            isOn: $privacyViewModel.isPublicAccount.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    Text("계정 공개 상태를 변경하여 나의 피드를 볼 수 있는 사람을 제한할 수 있습니다.")
                        .font(.pretendard(size: 12, weight: .regular))
                        .foregroundColor(Color(0xacacac))
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

                Divider()

                VStack(alignment: .leading, spacing: 22) {
                    Text("게시물")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("둘러보기 노출 허용")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Toggle(
                            isOn: $privacyViewModel.isPostBrowsingEnabled.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    HStack(spacing: 0) {
                        Text("피드 좋아요 허용")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Menu {
                            Button("허용 안함") {
                                privacyViewModel.isAllowFeedLike = "허용 안함"
                            }
                            Button("친구만") {
                                privacyViewModel.isAllowFeedLike = "친구만"
                            }
                            Button("모든 사람") {
                                privacyViewModel.isAllowFeedLike = "모든 사람"
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(privacyViewModel.isAllowFeedLike)
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0x1dafff))

//                                Image("back-button")
//                                    .renderingMode(.template)
//                                    .foregroundColor(Color(0x646464))
//                                    .opacity(0.5)
//                                    .rotationEffect(
//                                        Angle(
//                                            degrees: isAllowFeedLikeClicked ? 270 : 180
//                                        )
//                                    )
//                                    .frame(width: 28, height: 28)
                            }
                        }
                    }

                    HStack(spacing: 0) {
                        Text("피드 댓글 허용")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Menu {
                            Button("허용 안함") {
                                privacyViewModel.isAllowFeedComment = "허용 안함"
                            }
                            Button("친구만") {
                                privacyViewModel.isAllowFeedComment = "친구만"
                            }
                            Button("모든 사람") {
                                privacyViewModel.isAllowFeedComment = "모든 사람"
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(privacyViewModel.isAllowFeedComment)
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0x1dafff))

//                                Image("back-button")
//                                    .renderingMode(.template)
//                                    .foregroundColor(Color(0x646464))
//                                    .opacity(0.5)
//                                    .rotationEffect(
//                                        Angle(
//                                            degrees: isAllowFeedCommentClicked ? 270 : 180
//                                        )
//                                    )
//                                    .frame(width: 28, height: 28)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("나의 피드의 둘러보기 페이지 노출 여부를 선택할 수 있습니다.")
                            .font(.pretendard(size: 12, weight: .regular))
                            .foregroundColor(Color(0xacacac))

                        Text("피드에 좋아요와 코멘트를 남길 수 있는 대상 범위를 설정할 수 있습니다.")
                            .font(.pretendard(size: 12, weight: .regular))
                            .foregroundColor(Color(0xacacac))
                    }
                    .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)

                Divider()

                VStack(alignment: .leading, spacing: 22) {
                    Text("검색")
                        .font(.pretendard(size: 16, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("이메일로 검색 허용")
                            .font(.pretendard(size: 16, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Toggle(
                            isOn: $privacyViewModel.isAllowSearch.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    Text("둘러보기에서 나의 이메일 계정 검색을 제한할 수 있습니다. 이메일 검색이 제한되어도 계정 > 아이디 화면에서 설정된 아이디는 검색에 사용될 수 있습니다.")
                        .font(.pretendard(size: 12, weight: .regular))
                        .foregroundColor(Color(0xacacac))
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .contentShape(Rectangle())
    }
}
