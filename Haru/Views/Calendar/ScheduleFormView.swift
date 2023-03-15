//
//  ScheduleFormView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/15.
//

import SwiftUI

struct ScheduleFormView: View {
    @State var repeatStart: Date = .init()
    @State var repeatEnd: Date = .init()
    
    @State private var content: String = ""
    @State private var memo: String = ""
    
    @State private var alarmDate: Date = Date()

    @State private var showCategorySheet: Bool = false
    @State private var timeOption: Bool = false
    @State private var alarmOption: Bool = false
    @State private var repeatOption: Bool = false
    @State private var memoOption: Bool = false

    @State private var categoryList: [Category] = [Category(id: UUID().uuidString, content: "집"), Category(id: UUID().uuidString, content: "학교"), Category(id: UUID().uuidString, content: "친구")]
    @State private var selectionCategory: Int?

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Button {
                    print("close")
                } label: {
                    Image(systemName: "multiply")
                }

                Spacer()

                Button {
                    // TODO: 일정의 종료 시간이 일정의 시작 시간보다 빠르면 toast 알림창
                    print("complete")
                } label: {
                    Image(systemName: "checkmark")
                }
            }

            // 일정 입력
            Group {
                TextField("일정 입력", text: $content)
                    .font(Font.system(size: 20, weight: .bold))
                Divider()
            }

            // 카테고리 선택
            Group {
                HStack {
                    if let selectIndex = selectionCategory {
                        Circle()
                            .fill(Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]))
                            .overlay {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                            }
                            .frame(width: 20, height: 20)
                        Button("\(categoryList[selectIndex].content)") {
                            showCategorySheet = true
                        }
                        .sheet(isPresented: $showCategorySheet) {
                            CategoryView(categoryList: $categoryList, selectionCategory: $selectionCategory)
                                .presentationDetents([.medium])
                        }
                        .tint(Color.black)
                    } else {
                        Circle()
                            .strokeBorder(Color.gray, lineWidth: 1)
                            .frame(width: 20, height: 20)
                        Button("카테고리 선택") {
                            showCategorySheet = true
                        }
                        .sheet(isPresented: $showCategorySheet) {
                            CategoryView(categoryList: $categoryList, selectionCategory: $selectionCategory)
                                .presentationDetents([.medium])
                        }
                        .tint(Color.gray)
                    }

                    Spacer()
                }
                Divider()
            }

            // 시작일, 종료일 설정
            Group {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                    Text("시작일-종료일 설정")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle(isOn: $timeOption) {
                        Text("시간 설정")
                            .foregroundStyle(timeOption ? Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]) : Gradient(colors: [.gray, .gray]))
                    }
                    .toggleStyle(MyToggleStyle())
                }

                DatePicker(
                    "시작일",
                    selection: $repeatStart,
                    displayedComponents: timeOption ? [.date, .hourAndMinute] : [.date]
                )
                .datePickerStyle(.compact)

                DatePicker(
                    "종료일",
                    selection: $repeatEnd,
                    displayedComponents: timeOption ? [.date, .hourAndMinute] : [.date]
                )
                .datePickerStyle(.compact)

                Divider()
            }

            // 알람 설정
            Group {
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.gray)
                    Text("알림 설정")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $alarmOption.animation())
                        .toggleStyle(MyToggleStyle())
                }
                alarmOption ? AnyView(DatePicker(
                    "알람일",
                    selection: $alarmDate,
                    displayedComponents: [.date, .hourAndMinute]
                )) : AnyView(EmptyView())
                Divider()
            }

            // 반복 설정
            Group {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundStyle(.gray)
                    Text("반복 설정")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $repeatOption.animation())
                        .toggleStyle(MyToggleStyle())
                }
                Divider()
            }

            // 메모 추가
            Group {
                HStack {
                    Image(systemName: "doc")
                        .foregroundColor(.gray)
                    Text("메모 추가")
                        .foregroundColor(.gray)
                    Spacer()
                    Toggle("", isOn: $memoOption.animation())
                        .toggleStyle(MyToggleStyle())
                }

                memoOption ? AnyView(TextField("메모 작성", text: $memo, axis: .vertical)) : AnyView(EmptyView())
                Divider()
            }
        } // VStack
        .padding(.horizontal)
    }
}

struct ScheduleFormView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleFormView()
    }
}
