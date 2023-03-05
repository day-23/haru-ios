//
//  CustomDatePicker.swift
//  Haru
//
//  Created by 이준호 on 2023/03/06.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var currentDate: Date
    @Binding var startDisplayMode: CalendarWeekDisplayMode
    
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
                
                Button {
                    currentMonth -= 1
                    print(currentMonth)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                
                Button {
                    currentMonth += 1
                    print(currentMonth)
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
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
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
        
        VStack {
            if value.day != -1 {
                Text("\(value.day)")
                    .font(.title3.bold())
            } else {
                Text("-")
                    .font(.title3.bold())
                    .foregroundColor(Color.gray)
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60, alignment: .top)
    }
    
    
    
    func getDays() -> [String] {
        switch startDisplayMode {
        case .startingSun:
            return ["일", "월", "화", "수", "목", "금", "토"]
        case .startingMon:
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
        let calendar = Calendar.current
        
        // Getting Current Month Date ...
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap { date -> DateValue in
            // getting day ...
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        // adding offset days to get exact week day ...
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0 ..< firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        CustomDatePicker(currentDate: .constant(Date()), startDisplayMode: .constant(.startingSun))
    }
}
