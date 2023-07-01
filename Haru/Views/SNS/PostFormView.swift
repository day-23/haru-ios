//
//  PostFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/04.
//

import Mantis
import Photos
import SwiftUI

struct PostFormView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var postFormVM: PostFormViewModel

    @State var openPhoto: Bool
    @State var cancelWriting: Bool = false

    @FocusState private var isFocused: Bool
    @State private var requestPermission: Bool = false // 카메라 권한 요청

    // For pop up to root
    @Binding var rootIsActive: Bool
    @Binding var createPost: Bool

    var postAddMode: PostAddMode

    let deviceSize = UIScreen.main.bounds.size

    @State var selectedImageNum: Int = 0
    @State var isProgress: Bool = false

    @State private var croppedImage: UIImage?
    @State private var showingCropper = false
    @State private var showingCropShapeList = false
    @State private var cropShapeType: Mantis.CropShapeType = .rect
    @State private var presetFixedRatioType: Mantis.PresetFixedRatioType = .canUseMultiplePresetFixedRatio()

    @State private var showCamera = false
    @State var captureImage: UIImage?
//    @State private var showImagePicker = false
//    @State private var showSourceTypeSelection = false
//    @State private var sourceType: UIImagePickerController.SourceType?

    var body: some View {
        ScrollView(showsIndicators: false) {
            if postAddMode == .writing {
                TextField("", text: $postFormVM.content, axis: .vertical)
                    .placeholder(when: postFormVM.content.isEmpty, placeholder: {
                        Text("텍스트를 입력해주세요.")
                            .font(.pretendard(size: 24, weight: .regular))
                            .foregroundColor(Color(0xacacac))
                    })
                    .lineLimit(15)
                    .frame(alignment: .top)
                    .font(.pretendard(size: 24, weight: .bold))
                    .foregroundColor(Color(0x191919))
                    .background(Color(0xfdfdfd))
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .onChange(of: postFormVM.content) { value in
                        if value.count > 1000 {
                            postFormVM.content = String(
                                value[
                                    value.startIndex ..< value.index(value.endIndex, offsetBy: -1)
                                ]
                            )
                        }
                    }
            } else {
                VStack {
                    ZStack {
                        if !postFormVM.imageList.isEmpty {
                            Text("\(selectedImageNum + 1)/\(postFormVM.imageList.count)")
                                .font(.pretendard(size: 12, weight: .regular))
                                .foregroundColor(Color(0xfdfdfd))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 14)
                                .background(Color(0x191919).opacity(0.5))
                                .cornerRadius(15)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                                .offset(x: -10, y: 10)
                                .zIndex(2)
                        }

                        TabView(selection: $selectedImageNum) {
                            if postFormVM.imageList.count > 0 {
                                ForEach(postFormVM.imageList.indices, id: \.self) { idx in
                                    Image(uiImage: postFormVM.imageList[idx])
                                        .renderingMode(.original)
                                        .resizable()
                                        .frame(
                                            width: deviceSize.width,
                                            height: deviceSize.width
                                        )
                                        .clipped()
                                        .onTapGesture {
                                            croppedImage = postFormVM.oriImageList[selectedImageNum]
                                            presetFixedRatioType = .alwaysUsingOnePresetFixedRatio(ratio: 1)
                                            showingCropper = true
                                        }
                                        .overlay {
                                            if isProgress {
                                                ProgressView()
                                                    .frame(
                                                        width: deviceSize.width,
                                                        height: deviceSize.width
                                                    )
                                                    .background(Color(0x191919).opacity(0.4))
                                            }
                                        }
                                }
                            } else if isProgress {
                                ProgressView()
                                    .frame(
                                        width: deviceSize.width,
                                        height: deviceSize.width
                                    )
                                    .background(Color(0x191919).opacity(0.4))
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .zIndex(1)
                        .frame(width: deviceSize.width, height: deviceSize.width)
                    }
                }
                .padding(.top, 15)
            }
        }
        .background(Color(0xfdfdfd))
        .onTapGesture {
            if isFocused {
                hideKeyboard()
            } else {
                isFocused = true
            }
        }
        .fullScreenCover(isPresented: $showingCropper, content: {
            ImageCropper(image: $croppedImage,
                         cropShapeType: $cropShapeType,
                         presetFixedRatioType: $presetFixedRatioType)
                .onDisappear(perform: reset)
                .ignoresSafeArea()
        })
        .fullScreenCover(isPresented: $showCamera, content: {
            CameraView(image: $captureImage, isPopup: $showCamera, requestPermission: $requestPermission)
                .alert("'Haru'이(가) 카메라에 접근하려고 합니다.", isPresented: $requestPermission, actions: {
                    Button("허용") {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    Button("허용 안함") {
                        showCamera = false
                        requestPermission = false
                    }
                }, message: {
                    Text("하루에서 사진을 촬영하기 위해 카메라에 접근합니다.")
                })
                .ignoresSafeArea()
        })
        .onChange(of: croppedImage, perform: { _ in
            guard let image = croppedImage else { return }
            postFormVM.imageList[selectedImageNum] = image
        })
        .onChange(of: captureImage, perform: { _ in
            guard let image = captureImage else { return }
            if postFormVM.imageList.count < 10,
               let data = cropping(image: image)
            {
                postFormVM.oriImageList.append(image)
                postFormVM.imageList.append(data)
            }
        })
        .popupImagePicker(
            show: $openPhoto,
            activeCamera: $showCamera,
            mode: .multiple,
            always: true
        ) { assets in

            // MARK: Do Your Operation With PHAsset

            let manager = PHCachingImageManager.default()
            let options = PHImageRequestOptions()
            var result: [UIImage] = []
            var oriResult: [UIImage] = []
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

                        // 최종 uiimage 저장
                        guard let data = cropping(image: image) else {
                            print("크롭하는데 실패")
                            return
                        }

                        result.append(data)
                        oriResult.append(image)
                    }
                }

                DispatchQueue.main.async {
                    postFormVM.imageList = result
                    postFormVM.oriImageList = oriResult
                    isProgress = false
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    cancelWriting = true
                } label: {
                    Image("cancel")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
                .confirmationDialog(
                    "게시글 작성을 취소할까요? 작성 중인 내용은 삭제됩니다.",
                    isPresented: $cancelWriting,
                    titleVisibility: .visible
                ) {
                    Button("삭제하기", role: .destructive) {
                        dismissAction.callAsFunction()
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                Text(postAddMode == .drawing ? "하루 그리기" : "하루 쓰기")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    if postAddMode == .writing {
                        PostFormPreView(
                            postFormVM: postFormVM,
                            shouldPopToRootView: $rootIsActive,
                            createPost: $createPost
                        )
                    } else {
                        PostFormDrawingView(
                            postFormVM: postFormVM,
                            rootIsActive: $rootIsActive,
                            createPost: $createPost
                        )
                    }
                } label: {
                    Image("back-button")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x1dafff))
                        .rotationEffect(Angle(degrees: 180))
                }
                .disabled(postAddMode == .drawing ? postFormVM.imageList.isEmpty : postFormVM.content == "")
            }
        }
    }

    func reset() {
        cropShapeType = .rect
        presetFixedRatioType = .canUseMultiplePresetFixedRatio()
    }

    func cropping(image: UIImage) -> UIImage? {
        // 보이는 화면과 이미지의 비율 계산
        let imageViewScale = max(image.size.width / UIScreen.main.bounds.width,
                                 image.size.height / UIScreen.main.bounds.height)

        let cropZone = CGRect(x: 0,
                              y: 0,
                              width: UIScreen.main.bounds.width * imageViewScale,
                              height: UIScreen.main.bounds.width * imageViewScale)

        // 이미지 자르기
        guard let cutImageRef: CGImage = image.cgImage?.cropping(to: cropZone)
        else { return nil }

        // 최종 uiimage 저장
        return UIImage(cgImage: cutImageRef, scale: image.imageRendererFormat.scale, orientation: image.imageOrientation)
    }
}
