//
//  TagOptionView.swift
//  Haru
//
//  Created by 최정민 on 2023/04/24.
//

import SwiftUI

struct TagOptionView: View {
    private let width = UIScreen.main.bounds.width * 0.915
    private let height = UIScreen.main.bounds.height * 0.8

    var checkListViewModel: CheckListViewModel
    @State private var offset = CGSize.zero
    @Binding var isActive: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Text("태그 관리")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(Color(0xF8F8FA))
                    .padding(.top, 28)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 18)

                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 9) {
                            HStack(spacing: 0) {
                                Text("태그 추가")
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(Color(0xACACAC))
                                Spacer()

                                Image("plus")
                                    .renderingMode(.template)
                                    .frame(width: 28, height: 28)
                            }

                            ForEach(checkListViewModel.tagList) { tag in
                                TagOptionItem(tag: tag)
                            }
                        }
                        .padding(.top, 18)
                        .padding(.leading, 44)
                        .padding(.trailing, 30)
                    }

                    Text("완료")
                        .frame(width: 110, alignment: .center)
                        .font(.pretendard(size: 20, weight: .medium))
                        .foregroundColor(Color(0x1DAFFF))
                        .padding(.vertical, 13)
                        .onTapGesture {
                            withAnimation {
                                isActive = false
                            }
                        }
                }
                .frame(width: width, height: height * 0.86)
                .background(Color(0xFDFDFD))

                Spacer(minLength: 0)
            }
        }
        .frame(width: width, height: height)
        .background(
            RadialGradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF)], center: .center, startRadius: 0, endRadius: 350)
        )
        .cornerRadius(10, corners: [.topLeft, .bottomLeft])
        .offset(offset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.startLocation.x - value.location.x > 0 || value.translation.height != 0 {
                        return
                    }
                    offset = value.translation
                }
                .onEnded { value in
                    withAnimation {
                        if value.translation.width > width * 0.5 {
                            isActive = false
                        }
                        offset = .zero
                    }
                }
        )
    }
}

private struct TagOptionItem: View {
    var tag: Tag

    var body: some View {
        HStack {
            TagView(tag: tag, isSelected: true)

            Spacer()

            Menu {
                Button {} label: {
                    Label("Delete", systemImage: "trash")
                        .foregroundColor(Color(0xF71E58))
                }
            } label: {
                Image("ellipsis")
                    .renderingMode(.template)
                    .foregroundColor(Color(0x646464))
                    .frame(width: 28, height: 28)
            }
        }
    }
}
