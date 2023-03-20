//
//  CategoryView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/16.
//

import SwiftUI

struct CategoryView: View {
    @StateObject var scheduleFormVM: ScheduleFormViewModel

    @Binding var selectionCategory: Int?

    @State var showCategoryForm: Bool = false

    var body: some View {
        VStack {
            HStack {
                Text("카테고리 선택")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            .background(.gradation1)

            ScrollView {
                VStack(alignment: .leading) {
                    Group {
                        ForEach(Array(scheduleFormVM.categoryList.enumerated()),
                                id: \.offset) { index, category in
                            HStack {
                                if selectionCategory == index {
                                    Circle()
                                        .fill(.gradation1)
                                        .overlay {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 20, height: 20)
                                } else {
                                    Circle()
                                        .strokeBorder(.gray1, lineWidth: 1)
                                        .frame(width: 20, height: 20)
                                }

                                Image(systemName: "tag.fill")
                                    .foregroundColor(Color(category.color, true))

                                Text("\(category.content)")
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectionCategory = index
                            }
                            Divider()
                        }

                        if showCategoryForm {
                            CategoryFormView(scheduleFormVM: scheduleFormVM, showCategoryForm: $showCategoryForm)
                        }

                        Button {
                            withAnimation {
                                showCategoryForm = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("카테고리 추가")
                            }
                            .foregroundColor(.gray1)
                        }
                    }
                    .padding(.leading, 10)
                }
            }

            Spacer()
            Rectangle()
                .fill(.gradation1)
                .frame(height: 50)
        }
    }
}

// struct CategoryView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoryView(
//            categoryList: .constant([
//                Category(id: UUID().uuidString, content: "집"),
//                Category(id: UUID().uuidString, content: "학교"),
//                Category(id: UUID().uuidString, content: "친구"),
//            ]),
//            selectionCategory: .constant(nil)
//        )
//    }
// }
