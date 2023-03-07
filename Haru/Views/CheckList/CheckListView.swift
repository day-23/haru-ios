//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @ObservedObject var viewModel: CheckListViewModel
    @State private var isModalVisible: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.tagList) { tag in
                                TagView(tag)
                            }
                        }
                        .padding()
                    }

                    List {
                        ForEach(viewModel.todoList) { todo in
                            TodoView(todo: todo)
                                .frame(height: geometry.size.height * 0.06)
                        }
                    }
                    .listStyle(.inset)
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
                        TodoAddView()
                    }
                    .transition(.modal)
                    .zIndex(2)
                } else {
                    Button {
                        withAnimation {
                            isModalVisible = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .scaleEffect(2)
                            .padding(.all, 30)
                    }
                }
            }
        }
    }
}

struct CheckListView_Previews: PreviewProvider {
    static var previews: some View {
        CheckListView(viewModel: CheckListViewModel(service: TodoService()))
    }
}
