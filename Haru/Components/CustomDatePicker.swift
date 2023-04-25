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
            .background(Color(0xf1f1f5))
            .cornerRadius(10)
            .overlay {
                if isClicked {
                    ZStack {
                        Color.black.opacity(0.0001)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                isClicked = false
                            }

                        Picker(
                            selection: $selection,
                            now: selection
                        )
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

    @State var now: Date
    @State private var index: Int = 0

    private var dateList: [Date?] {
        var dateList: [Date?] = Array(repeating: nil, count: 42)
        let thisMonth = now.getAllDates()

        guard let offset = thisMonth.first?.indexOfWeek() else {
            return dateList
        }

        var index = offset
        while index < offset + thisMonth.count {
            dateList[index] = thisMonth[index - offset]
            index += 1
        }
        return dateList
    }

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

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text(formatter.string(from: now))
                    .font(.pretendard(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 28)
            .padding(.leading, 24)
            .background(.clear)

            TabView(selection: $index) {
                ForEach(-2 ... 2, id: \.self) { _ in
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach(days, id: \.self) { day in
                                    Text(day)
                                }
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(0xacacac))
                            }

                            Spacer(minLength: 9)

                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                ForEach(dateList, id: \.self) { day in
                                    if let day {
                                        if dateFormatter.string(from: day) == dateFormatter.string(from: selection) {
                                            Text(day.day.description)
                                                .frame(width: 22, height: 20)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(.white)
                                                .background(
                                                    Circle()
                                                        .frame(width: 28, height: 28)
                                                        .foregroundStyle(
                                                            LinearGradient(
                                                                colors: [Color(0xd2d7ff), Color(0xaad7ff)],
                                                                startPoint: .top,
                                                                endPoint: .bottom
                                                            )
                                                        )
                                                )
                                        } else {
                                            Text(day.day.description)
                                                .frame(width: 22, height: 20)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(
                                                    dateFormatter.string(from: day) == dateFormatter.string(from: .now) ?
                                                        Color(0x1dafff) : Color(0x646464)
                                                )
                                                .onTapGesture {
                                                    //  TODO: selection 변경하기
                                                }
                                        }
                                    } else {
                                        Text("")
                                            .frame(width: 22, height: 20)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color(0x646464))
                                    }
                                }
                                .padding(3)
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
        .background(RadialGradient(colors: [Color(0xaad7ff), Color(0xd2d7ff)],
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
