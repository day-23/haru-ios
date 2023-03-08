//
//  ScheduleService.swift
//  Haru
//
//  Created by 이준호 on 2023/03/07.
//

import Foundation

class ScheduleService {
    func fetchCurMonthScheduleList(_ currentMonth: Date) -> [Schedule] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return [
            Schedule(content: "복싱 가기", memo: "", startTime: formatter.date(from: "2023/03/07 21:00")!, endTime: formatter.date(from: "2023/03/07 22:00")!),
            Schedule(content: "정민이랑 점심 먹기", memo: "", startTime: formatter.date(from: "2023/03/07 12:00")!, endTime: formatter.date(from: "2023/03/07 13:00")!),
            Schedule(content: "홍석이랑 협곡 데이트", memo: "", startTime: formatter.date(from: "2023/03/09 20:00")!, endTime: formatter.date(from: "2023/03/09 22:00")!),
            Schedule(content: "알파프로젝트 회의", memo: "", startTime: formatter.date(from: "2023/03/11 13:30")!, endTime: formatter.date(from: "2023/03/11 18:00")!),
            Schedule(content: "장바구니", memo: "", startTime: formatter.date(from: "2023/03/12 10:00")!, endTime: formatter.date(from: "2023/03/15 16:00")!),
            Schedule(content: "내 생일", memo: "", startTime: formatter.date(from: "2023/03/19 00:00")!, endTime: formatter.date(from: "2023/03/19 23:59")!),
        ]
    }
}
