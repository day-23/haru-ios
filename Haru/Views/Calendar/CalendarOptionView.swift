//
//  CalendarOptionView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/21.
//

import SwiftUI

struct CalendarOptionView: View {
    @StateObject var calendarVM: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("카테고리 관리")
                    .foregroundColor(Color(0xfdfdfd))
                    .font(.pretendard(size: 24, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, 30)
            .padding(.top, 25)
            .padding(.bottom, 15)
            
            Group {
                VStack {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    Image("calendar-schedule")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .padding(.trailing, 6)
                                    
                                    Text("일정")
                                        .font(.pretendard(size: 16, weight: .bold))
                                }
                                .onTapGesture {
                                    calendarVM.allCategoryOff.toggle()
                                }
                                
                                Spacer()
                                
                                NavigationLink {
                                    CategoryFormView(calendarVM: calendarVM)
                                    
                                } label: {
                                    HStack(spacing: 5) {
                                        Text("카테고리 추가")
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(Color(0x646464))
                                        
                                        Image("todo-toggle")
                                            .resizable()
                                            .renderingMode(.template)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color(0x646464))
                                    }
                                }
                            }
                            .padding(.top, 22)
                            .padding(.horizontal, 20)
                            .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .gradientStart1)
                            
                            ForEach(calendarVM.categoryList.indices, id: \.self) { index in
                                HStack(spacing: 14) {
                                    Group {
                                        Circle()
                                            .strokeBorder(calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color))
                                            .background(Circle().foregroundColor(calendarVM.categoryList[index].isSelected ? calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color) : .white))
                                            .frame(width: 18, height: 18)
                                            .padding(.leading, 5)
                                        
                                        Text(calendarVM.categoryList[index].content)
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(
                                                calendarVM.categoryList[index].isSelected && !calendarVM.allCategoryOff ?
                                                    Color(0x191919) : .gray2)
                                    }
                                    .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .none)
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 10) {
                                        if index != 0, index != calendarVM.categoryList.count - 1 {
                                            NavigationLink {
                                                CategoryFormView(
                                                    content: calendarVM.categoryList[index].content,
                                                    color: Color(calendarVM.categoryList[index].color),
                                                    selectedIdx: getSelectedIdx(index: index),
                                                    calendarVM: calendarVM,
                                                    mode: .edit,
                                                    categoryId: calendarVM.categoryList[index].id
                                                )
                                            } label: {
                                                Image("sns-edit-pencil")
                                                    .renderingMode(.template)
                                                    .resizable()
                                                    .frame(width: 28, height: 28)
                                                    .foregroundColor(Color(0x191919))
                                            }
                                        }
                                        
                                        Button {
                                            if index == 0 {
                                                calendarVM.isUnknownCategorySelected.toggle()
                                            } else if index == calendarVM.categoryList.count - 1 {
                                                calendarVM.isHolidayCategorySelected.toggle()
                                            }
                                            calendarVM.categoryList[index].toggleIsSelected()
                                            
                                        } label: {
                                            if calendarVM.categoryList[index].isSelected, !calendarVM.allCategoryOff {
                                                Image("todo-tag-visible")
                                                
                                            } else {
                                                Image("todo-tag-hidden")
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }
                            
                            Divider()
                                .padding(.vertical, 19)
                            
                            HStack(spacing: 0) {
                                Image("calendar-todo")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 28, height: 28)
                                    .padding(.trailing, 6)
                                
                                Text("할 일")
                                    .font(.pretendard(size: 16, weight: .bold))
                                Spacer()
                            }
                            .onTapGesture {
                                calendarVM.allTodoOff.toggle()
                            }
                            .padding(.horizontal, 20)
                            .foregroundColor(calendarVM.allTodoOff ? .gray2 : .gradientStart1)
                            
                            Group {
                                HStack(spacing: 14) {
                                    Group {
                                        Circle()
                                            .strokeBorder(
                                                calendarVM.nonCompTodoOff || calendarVM.allTodoOff
                                                    ? .gray2 : Color(0x191919)
                                            )
                                            .background(Circle().foregroundColor(.white))
                                            .frame(width: 18, height: 18)
                                            .padding(.leading, 5)
                                        
                                        Text("미완료")
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(
                                                calendarVM.nonCompTodoOff || calendarVM.allTodoOff
                                                    ? .gray2 : Color(0x191919)
                                            )
                                    }
                                    
                                    Spacer()
                                    
                                    Button {
                                        calendarVM.nonCompTodoOff.toggle()
                                    } label: {
                                        if calendarVM.nonCompTodoOff || calendarVM.allTodoOff {
                                            Image("todo-tag-hidden")
                                        } else {
                                            Image("todo-tag-visible")
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                                
                                HStack(spacing: 14) {
                                    HStack(spacing: 0) {
                                        if calendarVM.compTodoOff || calendarVM.allTodoOff {
                                            Image("todo-circle-fill-gray")
                                        } else {
                                            Image("calendar-todo-option")
                                        }
                                        
                                        Text("완료")
                                            .font(.pretendard(size: 16, weight: .regular))
                                            .foregroundColor(
                                                calendarVM.compTodoOff || calendarVM.allTodoOff
                                                    ? .gray2 : Color(0x191919)
                                            )
                                            .padding(.leading, 9)
                                    }
                                    .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .none)
                                    
                                    Spacer()
                                    
                                    Button {
                                        calendarVM.compTodoOff.toggle()
                                    } label: {
                                        if calendarVM.compTodoOff || calendarVM.allTodoOff {
                                            Image("todo-tag-hidden")
                                        } else {
                                            Image("todo-tag-visible")
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            }
                            .foregroundColor(calendarVM.allTodoOff ? .gray2 : .none)
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button {
                            if calendarVM.allOff {
                                withAnimation {
                                    calendarVM.allCategoryOff = false
                                    calendarVM.allTodoOff = false
                                }
                            } else {
                                withAnimation {
                                    calendarVM.allCategoryOff = true
                                    calendarVM.allTodoOff = true
                                }
                            }
                        } label: {
                            Text(calendarVM.allOff ? "모두 표시" : "모두 가리기")
                                .font(.pretendard(size: 20, weight: .regular))
                                .foregroundColor(calendarVM.allOff ? Color(0x1dafff) : Color(0x646464))
                        }
                    }
                    .padding(.bottom, UIScreen.main.bounds.height < 800 ? 20 : 30)
                }
            }
            .background(Color(0xfdfdfd))
        }
    }
    
    func getSelectedIdx(index: Int) -> Int {
        for (row, colors) in Global.shared.colors.enumerated() {
            for (col, color) in colors.enumerated() {
                if color == Color(calendarVM.categoryList[index].color) {
                    return row * colors.count + col
                }
            }
        }
        return -1
    }
}
