//
//  CategoryFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import PopupView
import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) var dismissAction
    
    @State var content: String = ""
    @State var color: Color?
    @State var selectedIdx: Int = -1
    @State var isToggle: Bool = true
    @State var showToastMessage: Bool = false
    
    var disable: Bool {
        content == "" || selectedIdx == -1
    }
    
    var colors = Global.shared.colors
    
    var calendarVM: CalendarViewModel
    var mode: CategoryFormMode = .add
    var categoryId: String?

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 0) {
                HStack {
                    TextField("", text: $content)
                        .placeholder(when: content.isEmpty) {
                            Text("카테고리 이름을 입력하세요.")
                                .font(.pretendard(size: 24, weight: .regular))
                                .foregroundColor(Color(0xacacac))
                        }
                        .font(.pretendard(size: 24, weight: .bold))
                        .foregroundColor(Color(0x191919))
                        .onChange(of: content) { _ in
                            if content.count > 8 {
                                content = String(content[content.startIndex ..< content.index(content.endIndex, offsetBy: -1)])
                            }
                        }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                
                Divider()
                    .padding(.top, 24)
                    .padding(.bottom, 12)
                
                HStack {
                    Text("캘린더에 카테고리 표시")
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(!isToggle ? Color(0x646464) : Color(0x191919))
                    Spacer()
                    Toggle("", isOn: $isToggle.animation())
                        .toggleStyle(CustomToggleStyle())
                        .frame(width: 38, height: 18)
                }
                .padding(.horizontal, 30)
                .background(.white)
                
                Divider()
                    .padding(.vertical, 12)
                
                HStack {
                    Text("색상 선택")
                        .font(.pretendard(size: 14, weight: .regular))
                        .foregroundColor(selectedIdx == -1 ? Color(0x646464) : Color(0x191919))
                    Spacer()
                }
                .padding(.horizontal, 30)
                .background(.white)
                
                colorPicker()
                
                Spacer()
                
                if mode == .edit {
                    Button {
                        if let categoryId {
                            calendarVM.deleteCategory(categoryId: categoryId) {
                                calendarVM.getCategoryList()
                                dismissAction.callAsFunction()
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text("카테고리 삭제")
                                .font(.pretendard(size: 20, weight: .regular))
                                .foregroundColor(Color(0xf71e58))
                            Image("todo-delete")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(Color(0xf71e58))
                                .frame(width: 28, height: 28)
                        }
                    }
                }
            }
        }
        .padding(.top, 25)
        .padding(.bottom, 40)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text(mode == .add ? "카테고리 추가" : "카테고리 수정")
                    .font(.pretendard(size: 20, weight: .bold))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let alreadyExists = calendarVM.categoryList.contains { category in
                        category.content == content
                    }
                    
                    if alreadyExists {
                        showToastMessage = true
                        return
                    }
                    
                    if mode == .add {
                        calendarVM.addCategory(content, color?.toHex()) {
                            dismissAction.callAsFunction()
                        }
                        
                    } else if let categoryId {
                        calendarVM.updateCategory(categoryId: categoryId, content: content, color: color?.toHex()) {
                            calendarVM.getCategoryList()
                            dismissAction.callAsFunction()
                        }
                    }
                } label: {
                    Image("confirm")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color(0x191919))
                        .frame(width: 28, height: 28)
                }
                .disabled(disable)
            }
        }
        .popup(isPresented: $showToastMessage) {
            CustomToastMessage(message: "이미 동일한 카테고리명이 존재합니다.")
        } customize: { option in
            option
                .type(.floater())
                .position(.bottom)
                .animation(.easeInOut)
                .closeOnTap(true)
                .closeOnTapOutside(true)
                .autohideIn(2)
                .backgroundColor(.black.opacity(0.5))
        }
    }
    
    @ViewBuilder
    func colorPicker() -> some View {
        VStack(spacing: UIScreen.main.bounds.height < 800 ? 16 : 26) {
            ForEach(0 ... 6, id: \.self) { row in
                HStack(spacing: UIScreen.main.bounds.height < 800 ? 10 : 16) {
                    ForEach(colors[row].indices, id: \.self) { col in
                        ZStack {
                            Image("calendar-picked-circle")
                                .resizable()
                                .frame(width: 38, height: 38)
                                .opacity(row * colors[row].count + col == selectedIdx ? 1 : 0)
                            
                            Circle()
                                .fill(colors[row][col])
                                .frame(width: 28, height: 28)
                                .onTapGesture {
                                    selectedIdx = row * 6 + col
                                    selectColor()
                                }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .padding(.top, 12)
    }
    
    func selectColor() {
        let colCnt = colors[0].count
        if selectedIdx > 0 {
            color = colors[selectedIdx / colCnt][selectedIdx % colCnt]
        }
    }
}

struct CategoryFormView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryFormView(calendarVM: CalendarViewModel())
    }
}
