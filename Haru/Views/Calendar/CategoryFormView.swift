//
//  CategoryFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/17.
//

import SwiftUI

struct CategoryFormView: View {
    @Environment(\.dismiss) var dismissAction
    
    @State private var isColorModelVisible: Bool = false
    @State private var content: String = ""
    @State private var color: Color = .gradientStart1
    @State private var selectedIdx: Int = -1
    
    var colors = [
        [Color(0xFF0959), Color(0xFF509C), Color(0xFF5AB6), Color(0xFE7DCD), Color(0xFFAAE5), Color(0xFFBDFB)],
        
        [Color(0xB237BB), Color(0xC93DEB), Color(0xB34CED), Color(0x9D5BE3), Color(0xBB93F8), Color(0xC6B2FF)],
        
        [Color(0x4C45FF), Color(0x2E57FF), Color(0x4D8DFF), Color(0x45BDFF), Color(0x6DDDFF), Color(0x65F4FF)],
        
        [Color(0xFE7E7E), Color(0xFF572E), Color(0xC22E2E), Color(0xA07753), Color(0xE3942E), Color(0xE8A753)],
        
        [Color(0xFF892E), Color(0xFFAB4C), Color(0xFFD166), Color(0xFFDE2E), Color(0xCFE855), Color(0xB9D32E)],
        
        [Color(0x105C08), Color(0x39972E), Color(0x3EDB67), Color(0x55E1B6), Color(0x69FFD0), Color(0x05C5C0)],
    ]
    
    var calendarVM: CalendarViewModel

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                TextField("카테고리 입력", text: $content)
                    .font(.pretendard(size: 24, weight: .medium))
                    .padding(.horizontal, 30)
                Divider()
                HStack {
                    Text("색상")
                        .font(.pretendard(size: 14, weight: .medium))
                    Spacer()
                    Circle()
                        .fill(color)
                        .frame(width: 16, height: 16)
                }
                .padding(.horizontal, 30)
                .background(.white)
                .onTapGesture {
                    isColorModelVisible = true
                }
                
                Divider()
                Spacer()
                HStack {
                    Button {
                        dismissAction.callAsFunction()
                    } label: {
                        Text("취소")
                    }
                    Spacer()
                    Button {
                        calendarVM.addCategory(content, color.toHex()) {
                            dismissAction.callAsFunction()
                        }
                    } label: {
                        Text("추가")
                    }
                }
                .padding(.horizontal, 64)
            }
            
            if isColorModelVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        selectColor()
                        isColorModelVisible = false
                    }
                Modal(isActive: $isColorModelVisible, ratio: 0.9) {
                    colorPicker()
                }
                .zIndex(2)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismissAction.callAsFunction()
                } label: {
                    Image("back-button")
                        .frame(width: 28, height: 28)
                }
            }
        }
    }
    
    @ViewBuilder
    func colorPicker() -> some View {
        VStack(spacing: 35) {
            Text("색상 선택")
            ForEach(0 ... 5, id: \.self) { row in
                HStack(spacing: 25) {
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
                                }
                        }
                    }
                }
                .padding(.horizontal, 30)
            }
            Button {
                withAnimation {
                    selectColor()
                    isColorModelVisible = false
                }
            } label: {
                Text("확인")
            }
            Spacer()
        }
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
