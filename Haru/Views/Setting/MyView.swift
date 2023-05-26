//
//  MyView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/24.
//

import SwiftUI

struct MyView: View {
    @EnvironmentObject var global: Global
    @Binding var isLoggedIn: Bool
    @State private var now: Date = .now

    let dateFormatter: DateFormatter = {
        let formatter: DateFormatter = .init()
        formatter.dateFormat = "yyyy년 M월 나의 하루"
        return formatter
    }()

    var fromCreatedAt: Int {
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
        return Int(diff / (60 * 60 * 24))
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HaruHeader {
                    NavigationLink {
                        SettingView(isLoggedIn: $isLoggedIn)
                    } label: {
                        Image("setting")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x191919))
                            .frame(width: 28, height: 28)
                    }
                }

                ScrollView {
                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(.black)
                        Spacer()

                        VStack(spacing: 0) {
                            // 오늘 나의 하루
                            VStack(spacing: 20) {
                                HStack(spacing: 0) {
                                    Text(dateFormatter.string(from: now))
                                        .font(.pretendard(size: 14, weight: .bold))
                                        .foregroundColor(Color(0x191919))

                                    Spacer()

                                    HStack(spacing: 10) {
                                        Button {
                                            // TODO: 이전 달
                                        } label: {
                                            Image("back-button")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Color(0x191919))
                                                .opacity(0.5)
                                        }

                                        Text("\(now.month)월")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .foregroundColor(Color(0x646464))

                                        Button {
                                            // TODO: 다음 달
                                        } label: {
                                            Image("back-button")
                                                .renderingMode(.template)
                                                .resizable()
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(Color(0x191919))
                                                .opacity(0.5)
                                                .rotationEffect(Angle(degrees: 180))
                                        }
                                    }
                                }

                                HStack(spacing: 0) {
                                    VStack(spacing: 4) {
                                        Text("15")
                                            .font(.pretendard(size: 20, weight: .bold))
                                            .foregroundColor(Color(0x1dafff))
                                        Text("완료한 일")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .foregroundColor(Color(0x191919))
                                    }
                                    Spacer()
                                    VStack(spacing: 4) {
                                        Text("20")
                                            .font(.pretendard(size: 20, weight: .bold))
                                            .foregroundColor(Color(0x191919))
                                        Text("할 일")
                                            .font(.pretendard(size: 14, weight: .regular))
                                            .foregroundColor(Color(0x191919))
                                    }
                                }
                                .padding(.leading, 74)
                                .padding(.trailing, 81)

                                CircularProgressView(
                                    progress: 0.75
                                )
                                .overlay {
                                    Text("75%")
                                        .font(.pretendard(size: 30, weight: .bold))
                                        .foregroundColor(Color(0x1dafff))
                                }
                            }
                            .padding(.leading, 34)
                            .padding(.trailing, 20)

                            Divider()
                                .padding(.top, 28)
                                .padding(.bottom, 20)

                            // 하루와 함께한지 벌써
                            VStack(spacing: 20) {
                                Text("하루와 함께한지 벌써")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .foregroundColor(Color(0x191919))

                                HStack(spacing: 0) {
                                    Text("\(fromCreatedAt)")
                                        .font(.pretendard(size: 20, weight: .bold))
                                        .foregroundColor(Color(0x1dafff))
                                    Text("  일 째")
                                        .font(.pretendard(size: 14, weight: .regular))
                                        .foregroundColor(Color(0x191919))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.bottom, 8)

                                Image("haru-fighting")
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
                .trim(from: 0, to: progress)
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
