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
    @State var ratio: Double = 0.5

    var onEnd: () -> ()
    var onSelect: ([PHAsset]) -> ()

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
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
                                ratio = 0.5
                            }
                        } else if ratio == 0.5 {
                            withAnimation {
                                ratio = 0.15
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
                            if ratio == 0.5 {
                                withAnimation {
                                    ratio = 0.9
                                }
                            } else if ratio == 0.15 {
                                withAnimation {
                                    ratio = 0.5
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
                Image("sns-camera-disable")
                    .resizable()
                    .frame(width: 30, height: 30)
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

                                    let manager = PHCachingImageManager.default()
                                    manager.requestImage(for: imageAsset.asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFill, options: nil) { image, _ in
                                        imageAsset.thumbnail = image
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

        // MARK: Since its an Overlay View

        // Making It to Take Full Screen Space
        .frame(width: deviceSize.width, height: deviceSize.height, alignment: .bottom)
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
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
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

            if imagePickerModel.selectedImages.count >= 10 {
                return
            }

            withAnimation(.easeInOut) {
                if let index = imagePickerModel.selectedImages.firstIndex(where: { asset in
                    asset.id == imageAsset.id
                }) {
                    // MARK: Remove And Update Selected Index

                    imagePickerModel.selectedImages.remove(at: index)
                    imagePickerModel.selectedImages.enumerated().forEach { item in
                        imagePickerModel.selectedImages[item.offset].assetIndex = item.offset
                    }
                } else {
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
