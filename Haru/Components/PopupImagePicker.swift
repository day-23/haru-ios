//
//  ImagePicker.swift
//  Haru
//
//  Created by 이준호 on 2023/04/06.
//

import Foundation
import Photos
import PhotosUI
import SwiftUI

struct PopupImagePicker: View {
    @Environment(\.dismiss) var dismissAction
    @StateObject var imagePickerModel: ImagePickerViewModel = .init()

    @Environment(\.self) var env

    @State var multiSelectEnable: Bool = false
    @State private var requestPermission: Bool = false

    // MARK: Callbacks

    var mode: ImagePickerMode
    @Binding var activeCamera: Bool
    @State var ratio: Double = 0.43

    var onEnd: () -> ()
    var onSelect: ([PHAsset]) -> ()

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        let manager = PHImageManager.default()
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 10) {
                    Text("앨범")
                        .font(.pretendard(size: 20, weight: .bold))

                    Button {
                        if mode == .single {
                            withAnimation {
                                onEnd()
                            }
                        }

                        if ratio == 0.9 {
                            withAnimation {
                                ratio = 0.43
                            }
                        }
                    } label: {
                        Image("todo-toggle")
                            .renderingMode(.template)
                            .resizable()
                            .rotationEffect(.degrees(90))
                            .frame(width: 20, height: 20)
                    }

                    if mode == .multiple {
                        Button {
                            if ratio == 0.43 {
                                withAnimation {
                                    ratio = 0.9
                                }
                            }

                        } label: {
                            Image("todo-toggle")
                                .renderingMode(.template)
                                .resizable()
                                .rotationEffect(.degrees(270))
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .foregroundColor(Color(0x191919))

                Spacer()

                if mode == .multiple {
                    Button {
                        multiSelectEnable.toggle()
                        if multiSelectEnable == false,
                           imagePickerModel.selectedImages.count >= 1
                        {
                            imagePickerModel.selectedImages = [imagePickerModel.selectedImages[0]]
                        }
                    } label: {
                        Image(multiSelectEnable ? "sns-multiple-button" : "sns-multiple-button-disable")
                    }
                }
                Button {
                    activeCamera = true
                } label: {
                    Image("sns-camera-disable")
                        .resizable()
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.top, 25)
            .padding(.horizontal, 24)
            .padding(.bottom, 18)
            .contentShape(
                Rectangle()
            )

            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 3), spacing: 3) {
                    ForEach($imagePickerModel.fetchedImages) { $imageAsset in

                        // MARK: Grid Content

                        GridContent(imageAsset: imageAsset)
                            .onAppear {
                                if imageAsset.thumbnail == nil {
                                    // MARK: Fetching Thumbnail Image

                                    let options = PHImageRequestOptions()
                                    options.isNetworkAccessAllowed = true
                                    manager.requestImage(
                                        for: imageAsset.asset,
                                        targetSize: CGSize(width: 360, height: 360),
                                        contentMode: .aspectFill,
                                        options: options
                                    ) { image, _ in
                                        imageAsset.thumbnail = image
                                    }
                                }

                                if imagePickerModel.fetchedImages.firstIndex(where: { $0.id == imageAsset.id })
                                    == imagePickerModel.fetchedImages.count - 1
                                {
                                    Global.shared.toastMessageContent = "최근 \(min(200, imagePickerModel.fetchedImages.count))개의 사진을 모두 불러 왔습니다."
                                    Global.shared.toastMessageTheme = .dark
                                    withAnimation {
                                        Global.shared.showToastMessage = true
                                    }
                                }
                            }
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .frame(height: deviceSize.height * ratio)
        .frame(maxWidth: deviceSize.width)
        .background {
            Image("background-haru")
                .resizable()
        }
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(radius: 10)

        // MARK: Since its an Overlay View

        // Making It to Take Full Screen Space
        .frame(width: deviceSize.width, height: deviceSize.height, alignment: .bottom)
        .onAppear {
            // 사진 선택 허용이 처음인지 아닌지
            let albumStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch albumStatus {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    if status == .limited {
                        DispatchQueue.main.async {
                            self.imagePickerModel.fetchImages()
                        }
                    } else if status == .authorized {
                        DispatchQueue.main.async {
                            self.imagePickerModel.fetchImages()
                        }
                    } else {
                        dismissAction.callAsFunction()
                    }
                }
            case .restricted, .denied:
                requestPermission = true
            case .authorized, .limited:
                print("[Debug] 사진 권환 획득")
            @unknown default:
                fatalError()
            }
        }
        .alert("'Haru'이(가) 사용자의 사진에 접근하려고 합니다.", isPresented: $requestPermission) {
            Button("허용") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("허용 안 함") {
                dismissAction.callAsFunction()
            }
        } message: {
            Text("하루에서 사진을 추가하기 위해 앨범에 접근합니다.")
        }
    }

    // MARK: Grid Image Content

    @ViewBuilder
    func GridContent(imageAsset: ImageAsset) -> some View {
        let size = (UIScreen.main.bounds.size.width - 6) / 3
        let isSelected = imagePickerModel.selectedImages.contains { asset in
            asset.id == imageAsset.id
        }
        ZStack {
            if isSelected {
                Color.black.opacity(0.4)
                    .padding(2)
                    .zIndex(3)
            }

            if let thumbnail = imageAsset.thumbnail {
                Image(uiImage: thumbnail)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
                    .border(
                        width: isSelected ? 3 : 0,
                        edges: [.top, .bottom, .leading, .trailing],
                        color: Color(0x1AFFF)
                    )
            } else {
                ProgressView()
                    .frame(width: size, height: size, alignment: .center)
            }

            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(.black.opacity(0.1))

                Circle()
                    .fill(.white.opacity(0.25))

                Circle()
                    .stroke(.white, lineWidth: 1)

                if let index = imagePickerModel.selectedImages.firstIndex(where: { asset in
                    asset.id == imageAsset.id
                }) {
                    Circle()
                        .fill(Color(0x1DAFFF))

                    if multiSelectEnable {
                        Text("\(imagePickerModel.selectedImages[index].assetIndex + 1)")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 20, height: 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(x: -12, y: 12)
        }
        .clipped()
        .frame(width: size, height: size)
        .onTapGesture {
            // MARK: adding / Removing Asset

            withAnimation(.easeInOut) {
                if let index = imagePickerModel.selectedImages.firstIndex(where: { asset in
                    asset.id == imageAsset.id
                }) {
                    // MARK: Remove And Update Selected Index

                    imagePickerModel.selectedImages.remove(at: index)
                    imagePickerModel.selectedImages.enumerated().forEach { item in
                        imagePickerModel.selectedImages[item.offset].assetIndex = item.offset
                    }
                } else if imagePickerModel.selectedImages.count < 10 {
                    // MARK: Add New

                    var newAsset = imageAsset

                    if multiSelectEnable {
                        newAsset.assetIndex = imagePickerModel.selectedImages.count
                        imagePickerModel.selectedImages.append(newAsset)
                    } else {
                        newAsset.assetIndex = 0
                        imagePickerModel.selectedImages = [newAsset]
                    }
                }
            }

            let imageAssets = imagePickerModel.selectedImages.compactMap { imageAsset -> PHAsset? in
                imageAsset.asset
            }
            onSelect(imageAssets)
        }
    }
}
