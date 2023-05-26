//
//  CategoryFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) var dismissAction
    
    @State var content: String = ""
    @State var color: Color?
    @State var selectedIdx: Int = -1
    @State var isToggle: Bool = false
    
    var disable: Bool {
        content == "" || selectedIdx == -1
    }
    
    var colors = [
        [Color(0x2E2E2E), Color(0x656565), Color(0x818181), Color(0x9D9D9D), Color(0xB9B9B9), Color(0xD5D5D5)],
        
        [Color(0xFF0959), Color(0xFF509C), Color(0xFF5AB6), Color(0xFE7DCD), Color(0xFFAAE5), Color(0xFFBDFB)],
        
        [Color(0xB237BB), Color(0xC93DEB), Color(0xB34CED), Color(0x9D5BE3), Color(0xBB93F8), Color(0xC6B2FF)],
        
        [Color(0x4C45FF), Color(0x2E57FF), Color(0x4D8DFF), Color(0x45BDFF), Color(0x6DDDFF), Color(0x65F4FF)],
        
        [Color(0xFE7E7E), Color(0xFF572E), Color(0xC22E2E), Color(0xA07753), Color(0xE3942E), Color(0xE8A753)],
        
        [Color(0xFF892E), Color(0xFFAB4C), Color(0xFFD166), Color(0xFFDE2E), Color(0xCFE855), Color(0xB9D32E)],
        
        [Color(0x105C08), Color(0x39972E), Color(0x3EDB67), Color(0x55E1B6), Color(0x69FFD0), Color(0x05C5C0)],
    ]
    
    var calendarVM: CalendarViewModel
    var mode: CategoryFormMode = .add

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("카테고리 입력", text: $content)
                    .font(.pretendard(size: 24, weight: .medium))
                    
                Spacer()
                
                if content != "" {
                    Image("edit-pencil")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 30)
            Divider()
            HStack {
                Text("이벤트 알림")
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
                    print("삭제")
                } label: {
                    HStack(spacing: 10) {
                        Text("카테고리 삭제하기")
                            .font(.pretendard(size: 20, weight: .regular))
                            .foregroundColor(Color(0xF71E58))
                        Image("trash")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(0xF71E58))
                            .frame(width: 28, height: 28)
                    }
                }
            }
        }
        .onAppear {
            print(selectedIdx)
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
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if mode == .add {
                        calendarVM.addCategory(content, color?.toHex()) {
                            dismissAction.callAsFunction()
                        }
                    } else {
                        print("카테고리 편집")
                    }
                } label: {
                    Image("confirm")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(disable ? Color(0x646464) : Color(0x191919))
                        .frame(width: 28, height: 28)
                }
                .disabled(disable)
            }
        }
    }
    
    @ViewBuilder
    func colorPicker() -> some View {
        VStack(spacing: 30) {
            ForEach(0 ... 5, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(colors[row].indices, id: \.self) { col in
                        ZStack {
                            Image("circle")
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
        .padding(.top, 20)
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
