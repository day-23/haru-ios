//
//  MyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/24.
//

import SwiftUI

struct MyView: View {
    private let todoService: TodoService = .init()
    @EnvironmentObject var global: Global

    @StateObject var userProfileVM: UserProfileViewModel = .init(userId: Global.shared.user?.id ?? "unknown")

    @Binding var isLoggedIn: Bool
    @State private var now: Date = .now.startOfMonth()
    @State private var completed: Int = 0
    @State private var totalItems: Int = 0

    private var completionRate: Double {
        if self.totalItems == 0 {
            return 0
        }
        return Double(self.completed) / Double(self.totalItems)
    }

    private let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyy년 M월 나의 하루"
        return formatter
    }()

    private var fromCreatedAt: Int {
        guard let user = global.user else {
            return 0
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        guard let date = formatter
            .date(from: "\(Date.now.year)-\(Date.now.month)-\(Date.now.day)")
        else {
            return 0
        }

        let createdAt = user.createdAt
        let diff = createdAt.distance(to: date)
        return Int(diff / (60 * 60 * 24)) + 1
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader {
                    NavigationLink {
                        SettingView(isLoggedIn: self.$isLoggedIn, userProfileVM: self.userProfileVM)
                    } label: {
                        Image("setting")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                }

                ScrollView {
                    VStack(spacing: 0) {
                        // --- 프로필 view
                        ProfileInfoView(userProfileVM: self.userProfileVM)
                            .onAppear {
                                self.userProfileVM.fetchUserProfile()
                            }

                        Divider()
                            .padding(.top, 20)
                            .padding(.bottom, 20)

                        // 오늘 나의 하루
                        VStack(spacing: 20) {
                            HStack(spacing: 0) {
                                Text(self.dateFormatter.string(from: self.now))
                                    .font(.pretendard(size: 20, weight: .bold))
                                    .foregroundColor(Color(0x191919))

                                Spacer()

                                HStack(spacing: 10) {
                                    Button {
                                        guard let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: now) else {
                                            return
                                        }
                                        self.now = prevMonth
                                    } label: {
                                        Image("todo-toggle")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color(0x191919))
                                            .rotationEffect(Angle(degrees: 180))
                                            .opacity(0.5)
                                    }

                                    Text("\(self.now.month)월")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .foregroundColor(Color(0x646464))

                                    Button {
                                        guard let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: now) else {
                                            return
                                        }
                                        self.now = nextMonth
                                    } label: {
                                        Image("todo-toggle")
                                            .renderingMode(.template)
                                            .resizable()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(Color(0x191919))
                                            .opacity(0.5)
                                    }
                                }
                            }

                            HStack(spacing: 0) {
                                VStack(spacing: 4) {
                                    Text("\(self.completed)")
                                        .font(.pretendard(size: 20, weight: .bold))
                                        .foregroundColor(Color(0x1dafff))
                                        .animation(.none)
                                    Text("완료한 일")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                }
                                Spacer()
                                VStack(spacing: 4) {
                                    Text("\(self.totalItems)")
                                        .font(.pretendard(size: 20, weight: .bold))
                                        .foregroundColor(Color(0x191919))
                                        .animation(.none)
                                    Text("할 일")
                                        .font(.pretendard(size: 16, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                }
                            }
                            .padding(.leading, 74)
                            .padding(.trailing, 81)

                            CircularProgressView(
                                progress: self.completionRate
                            )
                            .overlay {
                                Text("\(Int(self.completionRate * 100))%")
                                    .font(.pretendard(size: 30, weight: .bold))
                                    .foregroundColor(Color(0x1dafff))
                                    .animation(.none)
                            }
                        }
                        .padding(.leading, 34)
                        .padding(.trailing, 20)

                        Divider()
                            .padding(.top, 28)
                            .padding(.bottom, 20)

                        // 하루와 함께한 지 벌써
                        VStack(spacing: 20) {
                            Text("하루와 함께한 지 벌써")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.pretendard(size: 20, weight: .bold))
                                .foregroundColor(Color(0x191919))

                            HStack(spacing: 0) {
                                Text("\(self.fromCreatedAt)")
                                    .font(.pretendard(size: 20, weight: .bold))
                                    .foregroundColor(Color(0x1dafff))
                                Text("  일 째")
                                    .font(.pretendard(size: 14, weight: .regular))
                                    .foregroundColor(Color(0x191919))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 8)

                            Image("setting-hagi-ruri")
                                .resizable()
                                .frame(width: 180, height: 125)
                        }
                        .padding(.leading, 34)
                        .padding(.trailing, 20)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .onAppear {
            self.todoService.fetchStatisticsByRange(
                startDate: self.now.startOfMonth(),
                endDate: self.now.endOfMonth().addDay().addingTimeInterval(-TimeInterval(1))
            ) { result in
                switch result {
                case let .success(success):
                    withAnimation {
                        self.completed = success.completed
                        self.totalItems = success.totalItems
                    }
                case .failure:
                    break
                }
            }
        }
        .onChange(of: self.now) { _ in
            self.todoService.fetchStatisticsByRange(
                startDate: self.now.startOfMonth(),
                endDate: self.now.endOfMonth().addDay().addingTimeInterval(-TimeInterval(1))
            ) { result in
                switch result {
                case let .success(success):
                    withAnimation {
                        self.completed = success.completed
                        self.totalItems = success.totalItems
                    }
                case .failure:
                    break
                }
            }
        }
    }
}

struct CircularProgressView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    Color(0xd2d7ff),
                    lineWidth: 10
                )
            Circle()
                .trim(from: 0, to: self.progress)
                .stroke(
                    Color(0x1dafff),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round
                    )
                ).rotationEffect(.degrees(-90))
        }
        .frame(width: 123, height: 123)
    }
}
