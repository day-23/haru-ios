//
//  ListSectionView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/23.
//

import SwiftUI

struct ListSectionView<Content>: View where Content: View {
    var checkListViewModel: CheckListViewModel
    var todoAddViewModel: TodoAddViewModel
    @Binding var todoList: [Todo]
    var itemBackgroundColor: Color = .white
    var emptyTextContent: String = "모든 할 일을 마쳤습니다!"
    let orderAction: () -> Void
    @ViewBuilder let header: () -> Content

    @State private var isCollapsed: Bool = false

    var body: some View {
        Section {
            if !isCollapsed {
                if todoList.isEmpty {
                    EmptySectionView(
                        content: emptyTextContent
                    )
                    .padding(.leading, 44)
                } else {
                    ForEach(todoList) { todo in
                        NavigationLink {
                            TodoAddView(viewModel: todoAddViewModel)
                                .onAppear {
                                    todoAddViewModel.applyTodoData(
                                        todo: todo,
                                        at: determineRepeatAt(todo: todo)
                                    )
                                }
                        } label: {
                            TodoView(
                                checkListViewModel: checkListViewModel,
                                todo: todo,
                                backgroundColor: itemBackgroundColor,
                                at: determineRepeatAt(todo: todo)
                            ) {
                                guard let index = todoList.firstIndex(where: { $0.id == todo.id }) else {
                                    return
                                }

                                withAnimation {
                                    todoList[index].completed.toggle()
                                }
                            } updateAction: {}
                                .foregroundColor(.black)
                        }

                        if !todo.folded {
                            ForEach(todo.subTodos) { subTodo in
                                SubTodoView(
                                    checkListViewModel: checkListViewModel,
                                    todo: todo,
                                    subTodo: subTodo,
                                    backgroundColor: itemBackgroundColor
                                )
                            }
                            .moveDisabled(true)
                        }
                    }
                    .onMove(perform: { indexSet, index in
                        // ScrollView로 변경함으로써 알고리즘 변경 필요
                        todoList.move(fromOffsets: indexSet, toOffset: index)
                        orderAction()
                    })
                }
            }
        } header: {
            HStack(spacing: 0) {
                Button {
                    withAnimation {
                        isCollapsed.toggle()
                    }
                } label: {
                    Image("todo-toggle")
                        .renderingMode(.template)
                        .frame(width: 20, height: 28)
                        .rotationEffect(Angle(degrees: isCollapsed ? 0 : 90))
                }
                .padding(.leading, 14)
                .foregroundColor(Color(0x646464))

                header()
                Spacer()
            }
            .background(itemBackgroundColor)
        }
    }
}

extension ListSectionView {
    func determineRepeatAt(todo: Todo) -> RepeatAt {
        if todo.repeatOption == nil {
            return .none
        }

        do {
            guard let _ = try todo.nextEndDate() else {
                return .none
            }
            return .front
        } catch {
            print("[Debug] 위치를 결정하는데 문제가 있습니다. \(error) \(#fileID) \(#function)")
        }

        return .none
    }
}
