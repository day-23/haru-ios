//
//  CategoryView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/16.
//

import SwiftUI

struct CategoryView: View {
    @ObservedObject var scheduleFormVM: ScheduleFormViewModel

    @Binding var selectedIdx: Int?
    @Binding var showCategorySheet: Bool

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
                                id: \.offset)
                        { index, category in
                            HStack(spacing: 20) {
                                Circle()
                                    .strokeBorder(Color(scheduleFormVM.categoryList[index].color))
                                    .background(Circle().foregroundColor(selectedIdx == index ? Color(scheduleFormVM.categoryList[index].color) : .white))
                                    .frame(width: 20, height: 20)

                                Text("\(category.content)")
                                    .font(.pretendard(size: 14, weight: .medium))
                                    .foregroundColor(selectedIdx == index ? .black : .gray1)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedIdx = index
                                Task {
                                    try? await Task.sleep(nanoseconds: 250_000_000)
                                    showCategorySheet = false
                                }
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
