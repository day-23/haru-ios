//
//  ProfileFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct ProfileFormView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var userProfileVM: UserProfileViewModel

    @State var openPhoto: Bool = false

    @State var image: UIImage? = nil
    @State var name: String
    @State var introduction: String

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 68)

                ZStack(alignment: .bottomTrailing) {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: 94, height: 94)
                            .clipShape(Circle())
                    } else {
                        if let profileImage = userProfileVM.user.profileImage {
                            ProfileImgView(imageUrl: URL(string: profileImage))
                                .frame(width: 94, height: 94)
                        } else {
                            Image("default-profile-image")
                                .resizable()
                                .clipShape(Circle())
                                .frame(width: 94, height: 94)
                        }
                    }
                    Image("camera")
                        .frame(width: 30, height: 30)
                }
                .onTapGesture {
                    openPhoto = true
                }

                Spacer()
                    .frame(height: 60)

                Group {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Text("이름")
                                .font(.pretendard(size: 14, weight: .bold))
                                .frame(width: 50, alignment: .leading)
                            TextField("이름을 입력하세요.", text: $name)
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                        Divider()
                        HStack(spacing: 20) {
                            Text("자기소개")
                                .font(.pretendard(size: 14, weight: .bold))
                            TextField("자기소개를 입력하세요.", text: $introduction)
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                        Divider()
                    }
                }
                .padding(.horizontal, 35)

                Spacer()
            }

            if openPhoto {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        openPhoto = false
                    }

                Modal(isActive: $openPhoto, ratio: 0.9) {
                    ImagePicker(sourceType: .photoLibrary, selectedImage: self.$image)
                }
                .zIndex(2)
            }
        }
        .customNavigationBar {
            Text("프로필 편집")
                .font(.pretendard(size: 20, weight: .bold))
        } leftView: {
            Button {
                dismissAction.callAsFunction()
            } label: {
                Image("back-button")
                    .frame(width: 28, height: 28)
            }
        } rightView: {
            Image("confirm")
                .renderingMode(.template)
                .foregroundColor(Color(0x191919))
        }
    }
}

// struct ProfileFormView_Previews: PreviewProvider {
//    static var snsVM: SNSViewModel = .init()
//    static var previews: some View {
//        ProfileFormView(snsVM: snsVM, name: "게으른 민수", introduction: "안녕하세요.")
//            .onAppear {
//                snsVM.fetchProfileImg()
//            }
//    }
// }
