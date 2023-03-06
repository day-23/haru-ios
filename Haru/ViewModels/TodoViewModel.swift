//
//  TodoViewModel.swift
//  Haru
//
//  Created by 최정민 on 2023/03/06.
//

import Foundation

final class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
}
