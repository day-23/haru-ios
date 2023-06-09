//
//  WithdrawalView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/02.
//

import SwiftUI

struct WithdrawalView: View {
    // MARK: Internal

    @Environment(\.dismiss) var dismissAction
    @EnvironmentObject var global: Global

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "계정 삭제") {
                self.dismissAction.callAsFunction()
            }
            .padding(.bottom, 20)

            Divider()
                .padding(.bottom, 20)

            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        if let profileImage = global.user?.user.profileImage,
                           let url = URL(string: profileImage)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Image("wifi-error")
                                    .resizable()
                            }
                            .clipShape(Circle())
                            .frame(width: 62, height: 62)
                        } else {
                            Image("background-main")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 62, height: 62)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(self.global.user?.user.name ?? "Unknown")
                                .font(.pretendard(size: 20, weight: .bold))
                            Text(self.global.user?.user.introduction ?? "자기소개를 적어보세요")
                                .font(.pretendard(size: 14, weight: .regular))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 20)

                    ZStack {
                        Color(0xf1f1f5)

                        VStack(alignment: .leading, spacing: 5) {
                            Text("연동된 이메일")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0x191919))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(self.global.user?.email ?? "unknown@haru.com")
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(Color(0x191919))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Spacer()
                        }
                        .padding(.top, 19)
                        .padding(.leading, 29)
                    }
                    .frame(height: 96)

                    VStack(alignment: .leading, spacing: 22) {
                        Text("계정이 삭제됩니다.")
                            .font(.pretendard(size: 14, weight: .bold))

                        Text("하루 계정이 삭제됩니다. 내 디바이스의 하루 데이터가 모두 삭제되며 닉네임, 사용자 아이디, 공개 프로필이 더 이상 하루 기록에 표시되지 않습니다. 실수로 계정을 삭제한 경우 30일 이내 복구가 가능합니다.")
                            .font(.pretendard(size: 12, weight: .regular))
                            .foregroundColor(Color(0xacacac))
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, 57)

                    Image("setting-hagi-ruri-crying")
                        .padding(.bottom, 54)

                    Button {
                        self.deleteButtonTapped = true
                    } label: {
                        Text("계정 삭제")
                            .font(.pretendard(size: 20, weight: .regular))
                            .foregroundColor(Color(0xf71e58))
                    }
                    .confirmationDialog(
                        "계정을 정말로 삭제하시나요?",
                        isPresented: self.$deleteButtonTapped,
                        titleVisibility: .visible
                    ) {
                        Button("삭제하기", role: .destructive) {
                            // TODO: 삭제하기 API 호출
                        }
                    }
                }
            }

            Spacer()
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: Private

    @State private var deleteButtonTapped: Bool = false
}

struct WithdrawalView_Previews: PreviewProvider {
    static var previews: some View {
        WithdrawalView()
            .environmentObject(Global.shared)
    }
}
