//
//  ScreenView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct ScreenView: View {
    @Environment(\.dismiss) var dismissAction

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct ScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ScreenView()
    }
}
