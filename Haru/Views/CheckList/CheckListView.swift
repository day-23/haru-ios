//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @StateObject var viewModel: CheckListViewModel
    @State private var isModalVisible: Bool = false
    @State private var isScrolled: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    // 태그 리스트
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            // 중요 태그
                            Image(systemName: "star.fill")
                                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .onTapGesture {}

                            // 미분류 태그
                            TagView(
                                Tag(id: "미분류", content: "미분류")
                            )

                            // 완료 태그
                            TagView(
                                Tag(id: "완료", content: "완료")
                            )

                            ForEach(viewModel.tagList) { tag in
                                TagView(tag)
                                    .onTapGesture {
                                        viewModel.fetchTodoListWithTag(tag) { _ in }
                                    }
                            }
                        }
                        .padding()
                    }

                    HStack {
                        Text("오늘 나의 하루")
                            .font(.system(size: 20, weight: .heavy))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .scaleEffect(1.25)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 15)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .leading, endPoint: .trailing)
                    )

                    // 체크 리스트
                    if viewModel.todoList.count > 0 {
                        List {
                            Group {
                                ListSectionView(viewModel: viewModel, todoList: viewModel.filterTodoByFlag()) {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(LinearGradient(gradient: Gradient(colors: [Constants.gradientEnd, Constants.gradientStart]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                }

                                Divider()

                                ListSectionView(viewModel: viewModel, todoList: viewModel.filterTodoByHasAnyTag()) {
                                    TagView(
                                        Tag(id: "분류됨", content: "분류됨")
                                    )
                                }

                                Divider()

                                ListSectionView(viewModel: viewModel, todoList: viewModel.filterTodoByWithoutTag()) {
                                    TagView(
                                        Tag(id: "미분류", content: "미분류")
                                    )
                                }
                            }.listRowSeparator(.hidden)
                        }
                        .listStyle(.inset)

                    } else {
                        VStack {
                            Text("모든 할 일을 마쳤습니다!")
                                .foregroundColor(Color(0x000000, opacity: 0.5))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }

                if isModalVisible {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(1)
                        .onTapGesture {
                            withAnimation {
                                isModalVisible = false
                            }
                        }

                    Modal(isActive: $isModalVisible, ratio: 0.9) {
                        TodoAddView(
                            viewModel: TodoAddViewModel(checkListViewModel: viewModel),
                            isActive: $isModalVisible
                        )
                    }
                    .transition(.modal)
                    .zIndex(2)
                } else {
                    if !isScrolled {
                        Button {
                            withAnimation {
                                isModalVisible = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .padding()
                                .background(LinearGradient(gradient: Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]), startPoint: .bottomTrailing, endPoint: .topLeading))
                                .clipShape(Circle())
                                .frame(alignment: .center)
                        }
                        .zIndex(5)
                        .padding()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchTodoList { _ in }
            viewModel.fetchTags { _ in }
        }
    }
}
