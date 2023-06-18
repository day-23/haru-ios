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
                    .foregroundColor(Color(0xfdfdfd))
                    .font(.pretendard(size: 24, weight: .bold))
                Spacer()
            }
            .background(
                Image("background-picker")
            )
            .padding(.top, 25)
            .padding(.horizontal, 24)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        ForEach(Array(scheduleFormVM.categoryList.enumerated()),
                                id: \.offset)
                        { index, category in
                            if category != Global.shared.holidayCategory,
                               index != 0
                            {
                                HStack(spacing: 14) {
                                    Circle()
                                        .strokeBorder(Color(scheduleFormVM.categoryList[index].color))
                                        .background(Circle().foregroundColor(selectedIdx == index ? Color(scheduleFormVM.categoryList[index].color) : .white))
                                        .frame(width: 18, height: 18)

                                    Text("\(category.content)")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .foregroundColor(
                                            selectedIdx == index ? Color(0x191919) : Color(0xacacac)
                                        )
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
                    }
                    .padding(.top, 15)
                    .padding(.leading, 20)
                }
            }
            .padding(.bottom, 10)
            .background(Color(0xfdfdfd))
        }
        .frame(width: 300, height: 480)
        .cornerRadius(10)
        .padding(.horizontal, 30)
        .shadow(radius: 2.0)
    }
}
