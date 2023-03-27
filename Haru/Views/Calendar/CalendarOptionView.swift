//
//  CalendarOptionView.swift
//  Haru
//
//  Created by 이준호 on 2023/03/21.
//

import SwiftUI

struct CalendarOptionView: View {
    @EnvironmentObject var calendarVM: CalendarViewModel

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("캘린더 보기 설정")
                    .foregroundColor(.white)
                    .font(.pretendard(size: 20, weight: .bold))
                Spacer()
            }
            .padding()
            .background(.gradation2)
            
            
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Image("calendar")
                        Text("일정")
                            .font(.pretendard(size: 14, weight: .bold))
                        Spacer()
                        Button {
                            
                        } label: {
                            Text("카테고리 추가")
                                .font(.pretendard(size: 14, weight: .regular))
                        }
                    }
                    .padding(.horizontal, 20)
                    .foregroundColor(.gradientStart1)
                    ForEach(calendarVM.categoryList.indices, id: \.self) { index in
                        HStack {
                            Group {
                                Circle()
                                    .strokeBorder(Color(calendarVM.categoryList[index].color, true))
                                    .background(Circle().foregroundColor(calendarVM.categoryList[index].isSelected ? Color(calendarVM.categoryList[index].color, true) : .white))
                                    .frame(width: 20, height: 20)
                                Text(calendarVM.categoryList[index].content)
                                Spacer()
                            }
                            .onTapGesture {
                                calendarVM.categoryList[index].toggleIsSelected()
                            }

                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray1)
                                .onTapGesture {
                                    print("편집")
                                }
                        }
                    }
                    .padding(.horizontal, 40)

                    Divider()

                    HStack {
                        Image("checkMark")
                        Text("할일")
                            .font(.pretendard(size: 14, weight: .bold))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .foregroundColor(.gradientStart1)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button {
                    print("dismiss")
                } label: {
                    Text("취소")
                }
                .tint(.red)
                Spacer()
                Button {
                    calendarVM.setAllCategoryList()
                } label: {
                    Text("완료")
                }
                .tint(.gradientStart1)
                Spacer()
            }
            Rectangle()
                .fill(.gradation2)
                .frame(height: 25)
        }
    }
}

struct CalendarOptionView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarOptionView()
            .environmentObject(CalendarViewModel())
    }
}
