//
//  PostFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/04.
//

import Photos
import SwiftUI

struct PostFormView: View {
    @Environment(\.dismiss) var dismissAction

    @StateObject var postFormVM: PostFormViewModel = .init()

    @State var openPhoto = true

    @FocusState private var isFocused: Bool

    // For pop up to root
    @Binding var rootIsActive: Bool

    var body: some View {
        TextField("텍스트를 입력해주세요.", text: $postFormVM.content, axis: .vertical)
            .lineLimit(nil)
            .frame(height: 400, alignment: .top)
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .background(Color(0xfdfdfd))
            .focused($isFocused)
            .onTapGesture {
                isFocused = true
            }
            .customNavigationBar {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("cancel")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            } rightView: {
                NavigationLink {
                    PostFormPreView(postFormVM: postFormVM, shouldPopToRootView: $rootIsActive)
                } label: {
                    HStack(spacing: 10) {
                        Text("하루 쓰기")
                            .font(.pretendard(size: 20, weight: .bold))
                        Image("toggle")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                    }
                }
                .foregroundColor(Color(0x191919))
            }
            .popupImagePicker(show: $openPhoto, mode: .multiple, always: true) { assets in

                // MARK: Do Your Operation With PHAsset

                // I'm Simply Extracting Image
                // .init() Means Exact Size of the Image
                let manager = PHCachingImageManager.default()
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                self.postFormVM.imageList = []
                DispatchQueue.global(qos: .userInteractive).async {
                    assets.forEach { asset in
                        manager.requestImage(for: asset, targetSize: .init(), contentMode: .default, options: options) { image, _ in
                            guard let image else { return }
                            DispatchQueue.main.async {
                                self.postFormVM.imageList.append(image)
                            }
                        }
                    }
                }
            }
    }
}
