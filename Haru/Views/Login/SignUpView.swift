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
            LinearGradient(
                colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 168.33, height: 84.74)
            .mask(
                Image("logo")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 168.33, height: 84.74)
            )
            .padding(.vertical, 30)

            ZStack(alignment: .bottomTrailing) {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 94, height: 94)
                        .clipShape(Circle())
                } else {
                    LinearGradient(
                        colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(Circle().frame(width: 94, height: 94))
                    .frame(width: 94, height: 94)
                }
                Image("camera")
                    .frame(width: 30, height: 30)
            }
            .onTapGesture {
                openPhoto = true
            }
            .padding(.bottom, 20)

            Group {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("하루 ID")
                            .font(.pretendard(size: 20, weight: .bold))

                        TextField("ID를 입력해 주세요.", text: $haruId)
                            .font(.pretendard(size: 24, weight: .regular))
                    }

                    Divider()

                    VStack(alignment: .leading, spacing: 0) {
                        Text("하루 ID는 타 사용자가 나의 계정을 검색할 때 외에 노출되지 않습니다.")
                            .lineLimit(1)
                        Text("ID는 초기 생성 이후 변경이 가능합니다.")
                    }
                    .font(.pretendard(size: 10, weight: .regular))
                    .foregroundColor(Color(0xACACAC))
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("닉네임")
                            .font(.pretendard(size: 20, weight: .bold))

                        TextField("최대 8글자를 입력해 주세요", text: $nickname)
                            .font(.pretendard(size: 24, weight: .regular))
                    }

                    Divider()
                }
            }
            .padding(.leading, 36)
            .padding(.trailing, 33)

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
                Text("프로필 생성 완료")
                    .font(.pretendard(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 13)
                    .padding(.horizontal, 104)
                    .background(
                        LinearGradient(
                            colors: [Color(0xD2D7FF), Color(0xAAD7FF)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
            }
            .padding(.top, 50)
        }
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
