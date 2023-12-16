//
//  ProfileFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Mantis
import Photos
import SwiftUI

struct ProfileFormView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var userProfileVM: UserProfileViewModel

    @State var openPhoto: Bool = false
    @State var showCamera: Bool = false

    @State var image: UIImage? = nil
    @State var name: String
    @State var introduction: String

    @State var isProgress: Bool = false

    @State private var showingCropper = false
    @State private var showingCropShapeList = false
    @State private var cropShapeType: Mantis.CropShapeType = .circle()
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio()

    @State private var requestPermission: Bool = false // 카메라 권한 요청

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
                        ProfileImgView(imageUrl: userProfileVM.profileImageURL)
                            .frame(width: 94, height: 94)
                            .clipShape(Circle())
                    }
                    Image("sns-edit-pencil")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.white)
                        .frame(width: 20, height: 20)
                        .background(
                            Image("sns-edit-circle")
                        )
                        .offset(x: -5)
                }
                .onTapGesture {
                    openPhoto = true
                }

                Spacer()
                    .frame(height: 60)

                Group {
                    VStack(spacing: 16) {
                        HStack(spacing: 20) {
                            Text("닉네임")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .frame(width: 58, alignment: .leading)
                            TextField("", text: $name)
                                .placeholder(when: name.isEmpty, placeholder: {
                                    Text("이름을 입력하세요.")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                })
                                .font(.pretendard(size: 16, weight: .bold))
                                .onChange(of: name) { _ in
                                    if name.count > 8 {
                                        let nameInput = name
                                        self.name = String(nameInput[nameInput.startIndex ..< nameInput.index(nameInput.endIndex, offsetBy: -1)])
                                    }
                                }
                        }
                        .padding(.horizontal, 15)
                        Divider()
                        HStack(spacing: 20) {
                            Text("자기소개")
                                .font(.pretendard(size: 16, weight: .regular))
                                .foregroundColor(Color(0x646464))
                                .frame(width: 58, alignment: .leading)
                            TextField("", text: $introduction)
                                .placeholder(when: introduction.isEmpty, placeholder: {
                                    Text("자기소개를 입력하세요.")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                })
                                .onChange(of: introduction) { _ in
                                    if introduction.count > 25 {
                                        let introInput = introduction
                                        self.introduction = String(introInput[introInput.startIndex ..< introInput.index(introInput.endIndex, offsetBy: -1)])
                                    }
                                }
                                .font(.pretendard(size: 16, weight: .bold))
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
        }
        .background(Color(0xfdfdfd))
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("프로필 편집")
                    .font(.pretendard(size: 20, weight: .bold))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation {
                        Dispatcher.dispatch(
                            action: Global.Actions.setIsLoading,
                            params: true,
                            for: Global.self
                        )
                    }

                    userProfileVM.updateUserProfile(name: name, introduction: introduction, profileImage: image) { result in
                        switch result {
                        case .success:
                            dismissAction.callAsFunction()
                        case .failure(let error):
                            switch error {
                            case ProfileService.ProfileError.invalid:
                                withAnimation {
                                    Dispatcher.dispatch(
                                        action: Global.Actions.showToastMessage,
                                        params: ["message": "사용할 수 없는 단어가 포함되어 있습니다."],
                                        for: Global.self
                                    )
                                }
                            default:
                                break
                            }
                        }
                        withAnimation {
                            Dispatcher.dispatch(
                                action: Global.Actions.setIsLoading,
                                params: false,
                                for: Global.self
                            )
                        }
                    }
                } label: {
                    Image("confirm")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera, content: {
            CameraView(image: $image, isPopup: $showCamera, requestPermission: $requestPermission)
                .alert("'Haru'이(가) 카메라에 접근하려고 합니다.", isPresented: $requestPermission, actions: {
                    Button("허용") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("허용 안함") {
                        showCamera = false
                        requestPermission = false
                    }
                }, message: {
                    Text("하루에서 사진을 촬영하기 위해 카메라에 접근합니다. 프로필 사진 첨부, 게시글 사진 첨부 기능 사용을 위해 카메라 접근권한 동의가 필요합니다. 설정에서 이를 변경할 수 있습니다.")
                })
                .ignoresSafeArea()
        })
        .fullScreenCover(isPresented: $showingCropper, content: {
            ImageCropper(image: $image,
                         cropShapeType: $cropShapeType,
                         presetFixedRatioType: $presetFixedRatioType)
                .onDisappear(perform: reset)
                .ignoresSafeArea()
        })
        .popupImagePicker(
            show: $openPhoto,
            activeCamera: $showCamera,
            mode: .single
        ) { assets in

            // MARK: Do Your Operation With PHAsset

            // I'm Simply Extracting Image
            // .init() Means Exact Size of the Image
            let manager = PHCachingImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            options.isNetworkAccessAllowed = true

            options.progressHandler = { progress, _, _, _ in
                if progress == 1.0 {
                    isProgress = false
                } else {
                    isProgress = true
                }
            }

            DispatchQueue.global(qos: .userInteractive).async {
                assets.forEach { asset in
                    manager.requestImage(for: asset, targetSize: .init(), contentMode: .aspectFit, options: options) { image, _ in
                        guard let image else { return }

                        DispatchQueue.main.async {
                            self.image = image
                            isProgress = false
                            self.showingCropper = true
                        }
                    }
                }
            }
        }
    }

    func reset() {
        cropShapeType = .circle()
        presetFixedRatioType = .canUseMultiplePresetFixedRatio()
    }
}
