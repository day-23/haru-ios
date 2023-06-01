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

    @State var openPhoto: Bool

    @FocusState private var isFocused: Bool

    // For pop up to root
    @Binding var rootIsActive: Bool

    var postAddMode: PostAddMode

    var body: some View {
        VStack {
            if postAddMode == .writing {
                TextField("텍스트를 입력해주세요.", text: $postFormVM.content, axis: .vertical)
                    .lineLimit(nil)
                    .frame(height: 400, alignment: .top)
                    .background(Color(0xfdfdfd))
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
            } else {
                if postFormVM.imageList.count != 0 {
                    Image(uiImage: postFormVM.imageList[0])
                        .resizable()
                        .frame(
                            width: UIScreen.main.bounds.size.width,
                            height: UIScreen.main.bounds.size.width
                        )
                }
            }
            Spacer()
        }
        .popupImagePicker(show: $openPhoto, mode: .multiple, always: true) { assets in

            // MARK: Do Your Operation With PHAsset

            // I'm Simply Extracting Image
            // .init() Means Exact Size of the Image
            let manager = PHCachingImageManager.default()
            let options = PHImageRequestOptions()
            options.isSynchronous = true
            postFormVM.imageList = []
            DispatchQueue.global(qos: .userInteractive).async {
                assets.forEach { asset in
                    manager.requestImage(for: asset, targetSize: .init(), contentMode: .default, options: options) { image, _ in
                        guard let image else { return }
                        DispatchQueue.main.async {
                            postFormVM.imageList.append(image)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("cancel")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }

            ToolbarItem(placement: .principal) {
                Text(postAddMode == .drawing ? "하루 그리기" : "하루 쓰기")
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0x191919))
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    PostFormPreView(postFormVM: postFormVM, shouldPopToRootView: $rootIsActive)
                } label: {
                    Image("toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
            }
        }
    }
}
