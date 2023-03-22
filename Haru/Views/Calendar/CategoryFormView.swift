//
//  CategoryFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import SwiftUI

struct CategoryFormView: View {
    @EnvironmentObject var scheduleFormVM: ScheduleFormViewModel

    @State var categoryContent: String = ""
    @State var categoryColor: Color = .gradientStart1

    @Binding var showCategoryForm: Bool

    let colors: [Color] = [.purple,
                           .red,
                           .orange,
                           .yellow,
                           .green,
                           .blue]

    var body: some View {
        VStack(alignment: .leading) {
            TextField("카테고리 입력", text: $categoryContent)
            HStack(spacing: 20) {
                ForEach(colors, id: \.self) { color in
                    Button(action: {
                        self.categoryColor = color
                    }) {
                        Image(systemName: self.categoryColor == color ? "checkmark.circle.fill" : "circle.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                    }.tint(color)
                }
            }
            Button {
                scheduleFormVM.addCategory(categoryContent, categoryColor.toHex())
                showCategoryForm = false
            } label: {
                Text("완료")
            }
        }
        .padding()
    }
}

// struct CategoryFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryFormView()
//    }
// }
