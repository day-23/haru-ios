//
//  TodoAddView.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import SwiftUI

struct TodoAddView: View {
    @Environment(\.dismiss) var dismissAction
    @ObservedObject var viewModel: TodoAddViewModel
    @Binding var isActive: Bool

    var body: some View {
        VStack {
            // Todo, SubTodo 입력 View
            VStack(alignment: .leading) {
                TextField("투두 입력", text: $viewModel.todoContent)
                    .padding(.horizontal, 20)
                    .font(.title)
                    .bold()

                ForEach(viewModel.subTodoList.indices, id: \.self) { index in
                    HStack {
                        Text("∙")
                        TextField("", text: $viewModel.subTodoList[index])
                        Button {
                            viewModel.subTodoList.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .foregroundStyle(Constants.lightGray)
                        }
                    }
                    Divider()
                }
                .padding(.horizontal, 30)

                Button {
                    viewModel.subTodoList.append("")
                } label: {
                    Label {
                        Text("하위 항목 추가")
                    } icon: {
                        Image(systemName: "plus")
                    }
                }
                .padding(.horizontal, 30)
                .foregroundColor(Constants.lightGray)

                Divider()
            }
            .padding(.horizontal, 30)

            // Tag 입력 View
            Label {
                TextField("태그", text: $viewModel.tag)
                    .foregroundColor(Constants.lightGray)
            } icon: {
                Image(systemName: "tag.fill")
                    .padding(.trailing, 10)
                    .foregroundColor(Constants.lightGray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)

            Divider()

            // 나의 하루에 추가
            Label {
                Toggle(isOn: $viewModel.isTodayTodo) {
                    Text("나의 하루에 추가")
                        .frame(alignment: .leading)
                        .foregroundColor(viewModel.isTodayTodo ? .black : Constants.lightGray)
                }
                .tint(LinearGradient(gradient: Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]), startPoint: .leading, endPoint: .trailing))
            } icon: {
                Image(systemName: "sun.max")
                    .padding(.trailing, 10)
                    .foregroundColor(viewModel.isTodayTodo ? .black : Constants.lightGray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)

            Divider()

            // 마감 설정
            Label {
                Toggle(isOn: $viewModel.isSelectedEndDate) {
                    Text("마감 설정")
                        .frame(alignment: .leading)
                        .foregroundColor(viewModel.isSelectedEndDate ? .black : Constants.lightGray)
                }
                .tint(LinearGradient(gradient: Gradient(colors: [Constants.gradientStart, Constants.gradientEnd]), startPoint: .leading, endPoint: .trailing))
            } icon: {
                Image(systemName: "calendar")
                    .padding(.trailing, 10)
                    .foregroundColor(viewModel.isSelectedEndDate ? .black : Constants.lightGray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 5)

            if viewModel.isSelectedEndDate {
                HStack {
                    Spacer()
                    DatePicker(selection: $viewModel.endDate, displayedComponents: [.date]) {}
                        .labelsHidden()
                    DatePicker(selection: $viewModel.endDateTime, displayedComponents: [.hourAndMinute]) {}
                        .labelsHidden()
                    Spacer()
                }
            }

            Divider()

            Spacer()
        }
        .onAppear {
            UIDatePicker.appearance().minuteInterval = 5
        }
    }
}

struct TodoAddView_Previews: PreviewProvider {
    static var previews: some View {
        TodoAddView(viewModel: TodoAddViewModel(checkListViewModel: CheckListViewModel()), isActive: .constant(true))
    }
}
