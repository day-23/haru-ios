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
        VStack(spacing: 10) {
            HStack {
                Text("카테고리 관리")
                    .foregroundColor(.white)
                    .font(.pretendard(size: 20, weight: .bold))
                Spacer()
            }
            .padding()
            .background(.gradation2)
                
            ScrollView {
                VStack(spacing: 15) {
                    HStack(alignment: .center, spacing: 14) {
                        Group {
                            Image("calendar")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 20, height: 20)
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
                            Image("plus")
                                .resizable()
                                .frame(width: 28, height: 28)
                        }
                    }
                    .padding(.init(top: 0, leading: 20, bottom: 0, trailing: 30))
                    .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .gradientStart1)
                    
                    ForEach(calendarVM.categoryList.indices, id: \.self) { index in
                        HStack(spacing: 14) {
                            Group {
                                Circle()
                                    .strokeBorder(calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color))
                                    .background(Circle().foregroundColor(calendarVM.categoryList[index].isSelected ? calendarVM.allCategoryOff ? .gray2 : Color(calendarVM.categoryList[index].color) : .white))
                                    .frame(width: 20, height: 20)
                                
                                Text(calendarVM.categoryList[index].content)
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(
                                        calendarVM.categoryList[index].isSelected && !calendarVM.allCategoryOff ?
                                            Color(0x191919) : .gray2)
                            }
                            .onTapGesture {
                                if index == 0 {
                                    calendarVM.isUnknownCategorySelected.toggle()
                                } else if index == calendarVM.categoryList.count - 1 {
                                    calendarVM.isHolidayCategorySelected.toggle()
                                }
                                calendarVM.categoryList[index].toggleIsSelected()
                            }
                            .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .none)
                            
                            Spacer()
                            
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
                                    Image("edit-pencil")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 28, height: 28)
                                        .foregroundColor(Color(0x646464))
                                }
                            }
                        }
                        .padding(.init(top: 0, leading: 20, bottom: 5, trailing: 30))
                    }
                    
                    Divider()
                    
                    HStack(spacing: 14) {
                        Image("checkMark")
                            .resizable()
                            .renderingMode(.template)
                            .frame(width: 20, height: 20)
                        
                        Text("할일")
                            .font(.pretendard(size: 16, weight: .bold))
                        Spacer()
                    }
                    .onTapGesture {
                        calendarVM.allTodoOff.toggle()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 5)
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
                                    .frame(width: 20, height: 20)
                                
                                Text("미완료")
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(
                                        calendarVM.nonCompTodoOff || calendarVM.allTodoOff
                                            ? .gray2 : Color(0x191919)
                                    )
                            }
                            .onTapGesture {
                                calendarVM.nonCompTodoOff.toggle()
                            }
                            
                            Spacer()
                        }
                        .padding(.init(top: 0, leading: 20, bottom: 5, trailing: 30))
                        
                        HStack(spacing: 14) {
                            Group {
                                Image("checkMark")
                                    .resizable()
                                    .renderingMode(.template)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(
                                        calendarVM.compTodoOff || calendarVM.allTodoOff
                                            ? .gray2 : .gradientStart1
                                    )
                                
                                Text("완료")
                                    .font(.pretendard(size: 16, weight: .regular))
                                    .foregroundColor(
                                        calendarVM.compTodoOff || calendarVM.allTodoOff
                                            ? .gray2 : Color(0x191919)
                                    )
                            }
                            .onTapGesture {
                                calendarVM.compTodoOff.toggle()
                            }
                            .foregroundColor(calendarVM.allCategoryOff ? .gray2 : .none)
                            
                            Spacer()
                        }
                        .padding(.init(top: 0, leading: 20, bottom: 5, trailing: 30))
                    }
                    .foregroundColor(calendarVM.allTodoOff ? .gray2 : .none)
                }
            }
                
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
                Text(calendarVM.allOff ? "모두 표시하기" : "모두 가리기")
                    .font(.pretendard(size: 20, weight: .regular))
                    .foregroundColor(calendarVM.allOff ? Color(0x1dafff) : Color(0x191919))
            }
            
            Rectangle()
                .fill(.gradation2)
                .frame(height: 25)
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

struct CalendarOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOptionView(calendarVM: CalendarViewModel())
    }
}
