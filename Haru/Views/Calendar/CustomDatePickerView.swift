//
//  CustomDatePicker.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var currentDate: Date // 현재 날짜의 연, 월, 일 정보 다 가지고 있음
    @State var startOnSunday: Bool = true
    
    // Month update on arrow button clicks ...
    @State var currentMonth: Int = 0
    
    var body: some View {
        VStack(spacing: 35) {
            // Days ...
            let days: [String] = getDays()
            
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                } // VStack
                
                Spacer(minLength: 0)
                Toggle("일요일 부터 시작", isOn: $startOnSunday)
                
                Button {
                    currentMonth -= 1
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Button {
                    currentMonth += 1
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            } // HStack
            .padding(.horizontal)
            
            // Day View ...
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            } // HStack
            
            // Dates ...
            let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
            
            LazyVGrid(columns: columns) {
                ForEach(extractDate()) { value in
                    CardView(value: value)
                }
            }
            
            Spacer()
        }
        .onChange(of: currentMonth) { newValue in
            
            // updating Month ...
            currentDate = getCurrentMonth()
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View {
        VStack(spacing: 5) {
            if !value.isPrevDate {
                Text("\(value.day)")
                    .font(.title3.bold())
            } else {
                Text("\(value.day)")
                    .font(.title3.bold())
                    .foregroundColor(Color.gray)
            }
            
            // TODO: 일정과 할일 보여줄 수 있게 만들기
        }
        .padding(.vertical, 8)
        .frame(width: UIScreen.main.bounds.width / 7, height: 100, alignment: .top)
    }
    
    func getDays() -> [String] {
        if startOnSunday {
            return ["일", "월", "화", "수", "목", "금", "토"]
        } else {
            return ["월", "화", "수", "목", "금", "토", "일"]
        }
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current
        
        // Getting Current Month Date ...
        guard let currentMonth = calendar.date(byAdding: .month, value: currentMonth, to: Date()) else {
            return Date()
        }
        
        return currentMonth
    }
    
    func extraDate() -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }
    
    func extractDate() -> [DateValue] {
        let calendar = Calendar.current // 현재 사용하고 있는 달력이 무엇인지 확인 (default: 그레고리)
        
        // Getting Current Month Date ...
        let currentMonth: Date = getCurrentMonth()
        
        var days: [DateValue] = currentMonth.getAllDates().compactMap { date -> DateValue in
            // getting day ...
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        // adding offset days to get exact week day ...
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        // 현재 월의 날이 아닌 day들의 DateValue 값을 -1로 채워넣어 위치를 맞춰준다
        if startOnSunday {
            for i in 1 ..< firstWeekday {
                guard let prevDate = calendar.date(byAdding: .day, value: -i, to: currentMonth.startOfMonth()) else {
                    break
                }
                days.insert(DateValue(day: calendar.component(.day, from: prevDate), date: prevDate, isPrevDate: true), at: 0)
            }
        } else {
            for _ in 0 ..< firstWeekday - 2 {
                days.insert(DateValue(day: -1, date: Date()), at: 0)
            }
        }
        
        return days
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomDatePicker(currentDate: .constant(Date()))
    }
}
