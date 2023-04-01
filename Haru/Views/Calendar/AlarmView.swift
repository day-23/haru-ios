//
//  AlarmView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/31.
//

import SwiftUI

struct AlarmView: View {
    @StateObject var scheduleVM: ScheduleFormViewModel

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(AlarmOption.allCases.indices, id: \.self) { index in
                    Text("\(AlarmOption.allCases[index].rawValue)")
                        .font(.pretendard(size: 14, weight: .medium))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 2)
                        .background(scheduleVM.selectIdxList[index] ? .white : .clear)
                        .cornerRadius(8)
                        .onTapGesture {
                            scheduleVM.selectIdxList[index].toggle()
                        }
                }
            }
            .padding(3)
            .background(Color(0xF1F1F5))
            .cornerRadius(10)
        }
    }
}

// struct AlarmView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlarmView()
//    }
// }
