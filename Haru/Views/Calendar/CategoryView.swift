//
//  CategoryView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/16.
//

import SwiftUI

struct CategoryView: View {
    @EnvironmentObject var scheduleFormVM: ScheduleFormViewModel

    @Binding var selectedIdx: Int?

    var body: some View {
        VStack {
            HStack {
                Text("카테고리 선택")
                    .foregroundColor(.white)
                    .font(.pretendard(size: 20, weight: .bold))
                Spacer()
            }
            .padding(.vertical, 28)
            .padding(.horizontal, 24)
            .background(.gradation2)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        ForEach(Array(scheduleFormVM.categoryList.enumerated()),
                                id: \.offset) { index, category in
                            HStack(spacing: 20) {
                                Circle()
                                    .strokeBorder(Color(scheduleFormVM.categoryList[index].color, true))
                                    .background(Circle().foregroundColor(selectedIdx == index ? Color(scheduleFormVM.categoryList[index].color, true) : .white))
                                    .frame(width: 20, height: 20)

                                Text("\(category.content)")
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(selectedIdx == index ? .black : .gray1)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                self.selectedIdx = index
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
            }

            Spacer()
            Rectangle()
                .fill(.gradation2)
                .frame(height: 25)
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
