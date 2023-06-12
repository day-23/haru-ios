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
    @Binding var createPost: Bool

    var postAddMode: PostAddMode

    let deviceSize = UIScreen.main.bounds.size

    var body: some View {
        ScrollView {
            if postAddMode == .writing {
                TextField("텍스트를 입력해주세요.", text: $postFormVM.content, axis: .vertical)
                    .lineLimit(nil)
                    .frame(alignment: .top)
                    .font(.pretendard(size: 24, weight: .regular))
                    .background(Color(0xfdfdfd))
                    .focused($isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
            } else {
                TabView {
                    ForEach(postFormVM.imageList.indices, id: \.self) { idx in
                        Image(uiImage: postFormVM.imageList[idx])
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: deviceSize.width,
                                height: deviceSize.width
                            )
                            .clipped()
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .frame(width: deviceSize.width, height: deviceSize.width)
                .padding(.top, 24)
            }
        }
        .background(Color(0xfdfdfd))
        .onTapGesture {
            hideKeyboard()
        }
        .popupImagePicker(
            show: $openPhoto,
            mode: .multiple,
            always: true
        ) { assets in

            // MARK: Do Your Operation With PHAsset

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
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                }
                .disabled(postAddMode == .drawing ? postFormVM.imageList.isEmpty : postFormVM.content == "")
            }
        }
    }
}
