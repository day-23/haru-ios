//
//  CustomDatePicker.swift
//  Haru
//
//  Created by 최정민 on 2023/03/24.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selection: Date
    var displayedComponents: [DatePicker.Components] = [.date]

    @State private var isClicked: Bool = false
    @State private var tapLocation: CGPoint = .zero

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EEE"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        return formatter
    }()

    var body: some View {
        Text(formatter.string(from: selection))
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color(0x646464))
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(Color(0xF1F1F5))
            .cornerRadius(10)
            .overlay {
                if isClicked {
                    ZStack {
                        Color.black.opacity(0.0001)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isClicked = false
                            }

                        Picker(selection: $selection)
                            .position(x: UIScreen.main.bounds.width / 2,
                                      y: tapLocation.y > UIScreen.main.bounds.height / 2 ?
                                          tapLocation.y - 210 : tapLocation.y + 210)
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                }
            }
            .onTapGesture(coordinateSpace: .global) { location in
                if !isClicked {
                    isClicked = true
                    tapLocation = location
                }
            }
    }
}

private struct Picker: View {
    @Binding var selection: Date

    @State var dateList: [[Date]] = Array(repeating: Array(repeating: Date.now, count: 7), count: 6)
    private let days = ["일", "월", "화", "수", "목", "금", "토"]

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text(formatter.string(from: selection))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 24)
                    .padding(.top, 28)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .frame(height: 70)
            .background(.clear)

            TabView {
                ForEach(-20 ... 20, id: \.self) { _ in
                    VStack {
                        VStack {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                Group {
                                    ForEach(days, id: \.self) { day in
                                        Text(day)
                                    }
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(0xACACAC))
                            }

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach((1 ... 42).indices, id: \.self) { day in
                                    Text("\(day.hashValue)")
                                        .frame(width: 22, height: 20)
                                }
                            }
                        }
                        .padding(.all, 27)
                    }
                    .frame(height: 254)
                    .background(.white)
                }
            }
            .tabViewStyle(.page)

            Rectangle()
                .frame(height: 26)
                .foregroundStyle(.clear)
                .background(.clear)
        }
        .frame(width: 300, height: 350)
        .background(RadialGradient(colors: [Color(0xAAD7FF), Color(0xD2D7FF)],
                                   center: .center,
                                   startRadius: 20,
                                   endRadius: 200))
        .cornerRadius(10)
        .shadow(color: Color(0x000000, opacity: 0.16), radius: 20)
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomDatePicker(selection: .constant(.now))
    }
}
