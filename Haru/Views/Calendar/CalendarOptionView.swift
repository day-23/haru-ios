//
//  CalendarOptionView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/21.
//

import SwiftUI

struct CalendarOptionView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel

    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(calendarVM.categoryList.indices, id: \.self) { index in
                        HStack {
                            Group {
                                Circle()
                                    .strokeBorder(Color(calendarVM.categoryList[index].color, true))
                                    .background(Circle().foregroundColor(calendarVM.categoryList[index].isSelected ? Color(calendarVM.categoryList[index].color, true) : .white))
                                    .frame(width: 20, height: 20)
                                Text(calendarVM.categoryList[index].content)
                                Spacer()
                            }
                            .onTapGesture {
                                calendarVM.categoryList[index].toggleIsSelected()
                            }

                            Image(systemName: "pencil")
                                .foregroundColor(.red)
                                .onTapGesture {
                                    print("편집")
                                }
                        }
                    }
                } header: {
                    HStack {
                        Text("카테고리")
                            .font(.pretendard(size: 14, weight: .regular))
                        Spacer()
                        Button {
                            print("모두 보이기 or 모두 감추기")
                        } label: {
                            Text("모두 보이기")
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                    }
                }
            } // List
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        calendarVM.setAllCategoryList()
                    } label: {
                        Text("완료")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        print("추가")
                    } label: {
                        Text("취소")
                    }
                    .tint(.red)
                }
            }
        }
    }
}

struct CalendarOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOptionView()
            .environmentObject(CalendarViewModel())
    }
}
