//
//  SignUpView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/25.
//

import Photos
import SwiftUI

struct SignUpView: View {
    private var profileService: ProfileService = .init()

    @State private var nickname: String = ""
    @State private var introduction: String = ""
    @State private var haruId: String = ""
    @State private var image: UIImage? = nil

    @State var openPhoto: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 94, height: 94)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 94, height: 94)
                }
                Image("camera")
                    .frame(width: 30, height: 30)
            }
            .onTapGesture {
                openPhoto = true
            }
            .padding(.top, 20)

            Spacer()
                .frame(height: 60)

            Group {
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        Text("닉네임")
                            .font(.pretendard(size: 14, weight: .bold))
                            .frame(width: 50, alignment: .leading)
                        TextField("닉네임을 입력해주세요.", text: $nickname)
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
                    HStack(spacing: 20) {
                        Text("ID")
                            .font(.pretendard(size: 14, weight: .bold))
                            .frame(width: 50, alignment: .leading)
                        TextField("검색에 사용될 ID를 입력해주세요.", text: $haruId)
                            .font(.pretendard(size: 14, weight: .regular))
                    }
                    Divider()
                }
            }
            .padding(.horizontal, 35)
        }
        .customNavigationBar(centerView: {
            Text("회원 가입")
                .font(.pretendard(size: 20, weight: .bold))
        }, leftView: {
            EmptyView()
        }, rightView: {
            Button {
                if let user = Global.shared.user {
                    if let image {
                        profileService.initUserProfileWithImage(
                            userId: user.id,
                            name: nickname,
                            introduction: introduction,
                            haruId: haruId,
                            profileImage: image
                        ) { result in
                            switch result {
                            case .success(let response):
                                // 로그인 되었음을 알려야 함
                                Global.shared.user = response
                            case .failure(let error):
                                print("[Debug] \(error) with Image \(#fileID) \(#function)")
                            }
                        }
                    } else {
                        profileService.initUserProfileWithoutImage(
                            userId: user.id,
                            name: nickname,
                            introduction: introduction,
                            haruId: haruId
                        ) { result in
                            switch result {
                            case .success(let response):
                                // 로그인 되었음을 알려야 함
                                Global.shared.user = response
                            case .failure(let error):
                                print("[Debug] \(error) without Image \(#fileID) \(#function)")
                            }
                        }
                    }
                }
            } label: {
                Image("confirm")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x191919))
            }
        })
        .popupImagePicker(show: $openPhoto, mode: .single) { assets in
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

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
