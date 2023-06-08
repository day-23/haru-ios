//
//  PrivacyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct PrivacyView: View {
    private let userService: UserService = .init()

    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var global: Global

    var body: some View {
        let isPublicAccount: Binding<Bool> = Binding {
            guard let user = self.global.user else {
                return false
            }
            return !user.user.isPublicAccount
        } set: {
            self.global.user?.user.isPublicAccount = !$0
            self.userService.updateUserOption(isPublicAccount: !$0) { _ in }
        }

        let isPostBrowsingEnabled: Binding<Bool> = Binding {
            guard let user = self.global.user else {
                return false
            }
            return user.isPostBrowsingEnabled
        } set: {
            self.global.user?.isPostBrowsingEnabled = $0
            self.userService.updateUserOption(isPostBrowsingEnabled: $0) { _ in }
        }

        let isAllowFeedLike: Binding<String> = Binding {
            guard let user = self.global.user else {
                return "허용 안함"
            }
            switch user.isAllowFeedLike {
            case 0:
                return "허용 안함"
            case 1:
                return "친구만"
            case 2:
                return "모든 사람"
            default:
                return "허용 안함"
            }
        } set: {
            switch $0 {
            case "허용 안함":
                self.global.user?.isAllowFeedLike = 0
                self.userService.updateUserOption(isAllowFeedLike: 0) { _ in }
            case "친구만":
                self.global.user?.isAllowFeedLike = 1
                self.userService.updateUserOption(isAllowFeedLike: 1) { _ in }
            case "모든 사람":
                self.global.user?.isAllowFeedLike = 2
                self.userService.updateUserOption(isAllowFeedLike: 2) { _ in }
            default:
                self.global.user?.isAllowFeedLike = 0
                self.userService.updateUserOption(isAllowFeedLike: 0) { _ in }
            }
        }

        let isAllowFeedComment: Binding<String> = Binding {
            guard let user = self.global.user else {
                return "허용 안함"
            }
            switch user.isAllowFeedComment {
            case 0:
                return "허용 안함"
            case 1:
                return "친구만"
            case 2:
                return "모든 사람"
            default:
                return "허용 안함"
            }
        } set: {
            switch $0 {
            case "허용 안함":
                self.global.user?.isAllowFeedComment = 0
                self.userService.updateUserOption(isAllowFeedComment: 0) { _ in }
            case "친구만":
                self.global.user?.isAllowFeedComment = 1
                self.userService.updateUserOption(isAllowFeedComment: 1) { _ in }
            case "모든 사람":
                self.global.user?.isAllowFeedComment = 2
                self.userService.updateUserOption(isAllowFeedComment: 2) { _ in }
            default:
                self.global.user?.isAllowFeedComment = 0
                self.userService.updateUserOption(isAllowFeedComment: 0) { _ in }
            }
        }

        let isAllowSearch: Binding<Bool> = Binding {
            guard let user = self.global.user else {
                return false
            }
            return user.isAllowSearch
        } set: {
            self.global.user?.isAllowSearch = $0
            self.userService.updateUserOption(isAllowSearch: $0) { _ in }
        }

        return VStack(spacing: 0) {
            SettingHeader(header: "개인정보 보호") {
                self.dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)
                .padding(.bottom, 20)

            VStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 22) {
                    Text("계정 공개")
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("계정을 비공개로 설정")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))
                            .padding(.trailing, 10)

                        Image("privacy-lock")
                            .resizable()
                            .frame(width: 20, height: 20)

                        Spacer()

                        Toggle(
                            isOn: isPublicAccount.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    Text("계정 공개 상태를 변경하여 나의 피드를 볼 수 있는 사람을 제한할 수 있습니다. 공개 계정일 경우 개별 카테고리에 대한 공개 설정은 카테고리 관리에서, 개별 게시글에 대한 공개 설정은 작성 시 설정할 수 있습니다.")
                        .font(.pretendard(size: 12, weight: .regular))
                        .foregroundColor(Color(0xACACAC))
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)

                Divider()

                VStack(alignment: .leading, spacing: 22) {
                    Text("게시물")
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("둘러보기 노출 허용")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Toggle(
                            isOn: isPostBrowsingEnabled.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    HStack(spacing: 0) {
                        Text("피드 좋아요 허용")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Menu {
                            Button("허용 안함") {
                                isAllowFeedLike.wrappedValue = "허용 안함"
                            }
                            Button("친구만") {
                                isAllowFeedLike.wrappedValue = "친구만"
                            }
                            Button("모든 사람") {
                                isAllowFeedLike.wrappedValue = "모든 사람"
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(isAllowFeedLike.wrappedValue)
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0x1DAFFF))

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
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Menu {
                            Button("허용 안함") {
                                isAllowFeedComment.wrappedValue = "허용 안함"
                            }
                            Button("친구만") {
                                isAllowFeedComment.wrappedValue = "친구만"
                            }
                            Button("모든 사람") {
                                isAllowFeedComment.wrappedValue = "모든 사람"
                            }
                        } label: {
                            HStack(spacing: 10) {
                                Text(isAllowFeedComment.wrappedValue)
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0x1DAFFF))

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
                            .foregroundColor(Color(0xACACAC))

                        Text("피드에 좋아요와 코멘트를 남길 수 있는 대상 범위를 설정할 수 있습니다.")
                            .font(.pretendard(size: 12, weight: .regular))
                            .foregroundColor(Color(0xACACAC))
                    }
                    .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)

                Divider()

                VStack(alignment: .leading, spacing: 22) {
                    Text("검색")
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    HStack(spacing: 0) {
                        Text("이메일로 검색 허용")
                            .font(.pretendard(size: 14, weight: .regular))
                            .foregroundColor(Color(0x646464))

                        Spacer()

                        Toggle(
                            isOn: isAllowSearch.animation()
                        ) {}
                            .toggleStyle(CustomToggleStyle())
                    }

                    Text("둘러보기에서 나의 이메일 계정 검색을 제한할 수 있습니다. 이메일 검색이 제한되어도 계정 > 아이디 화면에서 설정된 아이디는 검색에 사용될 수 있습니다.")
                        .font(.pretendard(size: 12, weight: .regular))
                        .foregroundColor(Color(0xACACAC))
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarBackButtonHidden()
        .contentShape(Rectangle())
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
            .environmentObject(Global.shared)
    }
}
