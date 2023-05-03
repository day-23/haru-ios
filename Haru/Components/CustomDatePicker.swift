//
//  CustomDatePicker.swift
//  Haru
//
//  Created by 최정민 on 2023/03/24.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selection: Date
    var displayedComponents: [DatePicker.Components]
    var pastCutoffDate: Date?

    @State private var isDateClicked: Bool = false
    @State private var isTimeClicked: Bool = false

    init(
        selection: Binding<Date>,
        displayedComponents: [DatePicker.Components] = [.date, .hourAndMinute],
        pastCutoffDate: Date? = nil
    ) {
        _selection = selection
        self.displayedComponents = displayedComponents
        self.pastCutoffDate = pastCutoffDate
    }

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
        HStack(spacing: 8) {
            if displayedComponents.contains(.date) {
                Text(formatter.string(from: selection))
                    .font(.pretendard(size: 14, weight: .medium))
                    .foregroundColor(Color(0x646464))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color(0xf1f1f5))
                    .cornerRadius(10)
                    .onTapGesture { _ in
                        if !isDateClicked {
                            isDateClicked = true
                        }
                    }
                    .popover(isPresented: $isDateClicked, arrowDirection: .unknown) {
                        if let pastCutoffDate {
                            DatePicker(
                                "",
                                selection: $selection,
                                in: pastCutoffDate...,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        } else {
                            DatePicker(
                                "",
                                selection: $selection,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                        }
                    }
            }

            if displayedComponents.contains(.hourAndMinute) {
                Text(timeFormatter.string(from: selection))
                    .font(.pretendard(size: 14, weight: .medium))
                    .foregroundColor(Color(0x646464))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color(0xf1f1f5))
                    .cornerRadius(10)
                    .onTapGesture { _ in
                        if !isTimeClicked {
                            isTimeClicked = true
                        }
                    }
                    .popover(isPresented: $isTimeClicked, arrowDirection: .unknown) {
                        DatePicker(
                            "",
                            selection: $selection,
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(.wheel)
                    }
            }
        }
    }
}
