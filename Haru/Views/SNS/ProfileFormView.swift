//
//  ProfileFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Photos
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
            Button {
                userProfileVM.updateUserProfile(name: name, introduction: introduction, profileImage: image) { result in
                    switch result {
                    case .success:
                        self.dismissAction.callAsFunction()
                    case .failure(let error):
                        // TODO: 알럿창으로 바꿔주기
                        print("[Error] \(error)")
                    }
                }
            } label: {
                Image("confirm")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x191919))
            }
        }
        .popupImagePicker(show: $openPhoto, mode: .single) { assets in

            // MARK: Do Your Operation With PHAsset

            // I'm Simply Extracting Image
            // .init() Means Exact Size of the Image
            let manager = PHCachingImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            DispatchQueue.global(qos: .userInteractive).async {
                assets.forEach { asset in
                    manager.requestImage(for: asset, targetSize: .init(), contentMode: .default, options: options) { image, _ in
                        guard let image else { return }
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            }
        }
    }
}
