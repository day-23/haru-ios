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

    @StateObject var postFormVM: PostFormViewModel

    @State var openPhoto: Bool
    @State var cancelWriting: Bool = false

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
                    .font(.pretendard(size: 24, weight: .regular))
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
            var result: [UIImage] = []
            options.isSynchronous = true
            DispatchQueue.global(qos: .userInteractive).async {
                assets.forEach { asset in
                    manager.requestImage(for: asset, targetSize: .init(), contentMode: .aspectFit, options: options) { image, _ in
                        guard let image else { return }
                        DispatchQueue.main.async {
                            result.append(image)
                        }
                    }
                }

                DispatchQueue.main.async {
                    postFormVM.imageList = result
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
                    PostFormPreView(postFormVM: postFormVM, shouldPopToRootView: $rootIsActive)
                } label: {
                    Image("toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
                .disabled(postAddMode == .drawing ? postFormVM.imageList.isEmpty : postFormVM.content == "")
            }
        }
    }
}
