//
//  ImagePicker.swift
//  Haru
//
//  Created by 이준호 on 2023/04/06.
//

import Foundation
import PhotosUI
import SwiftUI

struct PopupImagePicker: View {
    @StateObject var imagePickerModel: ImagePickerViewModel = .init()

    @Environment(\.self) var env

    @State var multiSelectEnable: Bool = false

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
                                    Global.shared.toastMessageContent = "최근 200개의 사진을 모두 불러 왔습니다."
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
        .frame(width: deviceSize.width, height: deviceSize.height, alignment: .bottom)
        .gesture(
            DragGesture()
                .onChanged { value in
                    let y = value.location.y
                    let newer = 1 - y / deviceSize.height
                    ratio = max(0.43, min(0.9, newer))
                }
        )
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
