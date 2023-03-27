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
        VStack(spacing: 10) {
            HStack {
                Text("캘린더 보기 설정")
                    .foregroundColor(.white)
                    .font(.pretendard(size: 20, weight: .bold))
                Spacer()
            }
            .padding()
            .background(.gradation2)
                
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Group {
                            Image("calendar")
                                .renderingMode(.template)
                            Text("일정")
                                .font(.pretendard(size: 14, weight: .bold))
                        }
                        .onTapGesture {
                            calendarVM.allCategoryOff.toggle()
                        }
                        Spacer()
                        
                        Image("plus")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 40))
                    .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .gradientStart1)
                        
                    ForEach(calendarVM.categoryList.indices, id: \.self) { index in
                        HStack {
                            Group {
                                Circle()
                                    .strokeBorder(calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color, true))
                                    .background(Circle().foregroundColor(calendarVM.categoryList[index].isSelected ? calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color, true) : .white))
                                    .frame(width: 20, height: 20)
                                Text(calendarVM.categoryList[index].content)
                                Spacer()
                            }
                            .onTapGesture {
                                calendarVM.categoryList[index].toggleIsSelected()
                            }
                            .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .none)
                                
                            Image("ellipsis")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(.gray2)
                                .onTapGesture {
                                    print("편집")
                                }
                        }
                    }
                    .padding(.horizontal, 40)
                        
                    Divider()
                        
                    HStack {
                        Image("checkMark")
                            .renderingMode(.template)
                        Text("할일")
                            .font(.pretendard(size: 14, weight: .bold))
                        Spacer()
                    }
                    .onTapGesture {
                        calendarVM.allTodoOff.toggle()
                    }
                    .padding(.horizontal, 20)
                    .foregroundColor(calendarVM.allTodoOff ? .gray2 : .gradientStart1)
                }
            }
                
            Spacer()
                
            HStack {
                Spacer()
                Button {
                    calendarVM.allCategoryOff = true
                    calendarVM.allTodoOff = true
                } label: {
                    Text("모두 가리기")
                        .font(.pretendard(size: 20, weight: .medium))
                }
                .tint(.mainBlack)
                Spacer()
                Button {
                    calendarVM.setAllCategoryList()
                } label: {
                    Text("완료")
                        .font(.pretendard(size: 20, weight: .medium))
                }
                .tint(.gradientStart1)
                Spacer()
            }
            Rectangle()
                .fill(.gradation2)
                .frame(height: 25)
        }
    }
}

struct CalendarOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOptionView()
            .environmentObject(CalendarViewModel())
    }
}
