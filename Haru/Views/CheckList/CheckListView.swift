//
//  CheckListView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import SwiftUI

struct CheckListView: View {
    @ObservedObject var viewModel: CheckListViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    List {
                        ForEach(viewModel.todoList) { todo in
                            TodoView(todo: todo)
                                .frame(height: geometry.size.height * 0.06)
                        }
                    }
                }
            }
        }
    }
}
