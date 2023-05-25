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

    @State var enable: Bool = false

    // MARK: Callbacks

    var mode: ImagePickerMode
    var onEnd: () -> ()
    var onSelect: ([PHAsset]) -> ()

    var body: some View {
        let deviceSize = UIScreen.main.bounds.size
        VStack(spacing: 0) {
            HStack {
                Button {
                    if mode == .single {
                        onEnd()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Text("갤러리")
                            .font(.pretendard(size: 20, weight: .bold))
                        Image("toggle")
                            .renderingMode(.template)
                            .resizable()
                            .rotationEffect(.degrees(90))
                            .frame(width: 20, height: 20)
                    }
                }
                .foregroundColor(Color(0x191919))

                Spacer()

                if mode == .multiple {
                    Button {
                        enable.toggle()
                    } label: {
                        Image(enable ? "enable-select-photo" : "disable-select-photo")
                    }
                }
                Image("default-camera")
                    .resizable()
                    .frame(width: 30, height: 30)
            }
            .padding(.top, 27)
            .padding(.horizontal, 24)
            .padding(.bottom, 20)

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
                    }
                }
            }
        }
        .frame(height: deviceSize.height * 0.5)
        .frame(maxWidth: deviceSize.width)
        .background {
            Rectangle()
                .fill(LinearGradient(colors: [.gradientStart2, .gradientEnd2], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20, corners: [.topLeft, .topRight])
        }

        // MARK: Since its an Overlay View

        // Making It to Take Full Screen Space
        .frame(width: deviceSize.width, height: deviceSize.height, alignment: .bottom)
        // TODO: 하단 탭바 삭제하면 안해줘도 됨
//        .padding(.bottom, 110)
    }

    // MARK: Grid Image Content

    @ViewBuilder
    func GridContent(imageAsset: ImageAsset) -> some View {
        let size = (UIScreen.main.bounds.size.width - 6) / 3
        ZStack {
            if let thumbnail = imageAsset.thumbnail {
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
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
                        .fill(.blue)

                    Text("\(imagePickerModel.selectedImages[index].assetIndex + 1)")
                        .font(.caption2.bold())
                        .foregroundColor(.white)
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

            if mode == .multiple, !enable {
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
                    newAsset.assetIndex = imagePickerModel.selectedImages.count
                    imagePickerModel.selectedImages.append(newAsset)
                }
            }

            let imageAssets = imagePickerModel.selectedImages.compactMap { imageAsset -> PHAsset? in
                imageAsset.asset
            }
            onSelect(imageAssets)
        }
    }
}
