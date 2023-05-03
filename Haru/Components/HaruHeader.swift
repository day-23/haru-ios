//
//  HaruHeader.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

import SwiftUI

struct HaruHeader<SearchContent: View>: View {
    @Binding var toggleIsClicked: Bool

    var backgroundColor: Color = .white
    var backgroundGradient: Gradient?
    @ViewBuilder var searchView: SearchContent // 검색 버튼 눌렀을 때 이동할 뷰를 넘겨주면 된다.

    var body: some View {
        ZStack {
            if let backgroundGradient {
                LinearGradient(
                    gradient: backgroundGradient,
                    startPoint: .leading,
                    endPoint: .trailing
                ).ignoresSafeArea()
            } else {
                LinearGradient(
                    colors: [backgroundColor],
                    startPoint: .leading,
                    endPoint: .trailing
                ).ignoresSafeArea()
            }

            VStack(spacing: 0) {
                HStack {
                    Text("HARU")
                        .font(.pretendard(size: 20, weight: .bold))
                        .foregroundColor(Color(0x191919))

                    Button {
                        withAnimation {
                            toggleIsClicked.toggle()
                        }
                    } label: {
                        Image("toggle")
                            .renderingMode(.template)
                            .foregroundColor(Color(0x646464))
                            .rotationEffect(.degrees(toggleIsClicked ? 90 : 0))
                    }

                    Spacer()
                    NavigationLink {
                        searchView
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundColor(Color(0x191919))
                            .frame(width: 20, height: 20)
                    }
                }
                Spacer()
                    .frame(height: 20)
            }
            .padding(.leading, 20)
            .padding(.trailing, 23)
        }
        .frame(height: 42)
    }
}

struct HaruHeader_Previews: PreviewProvider {
    static var previews: some View {
        HaruHeader(toggleIsClicked: .constant(false)) {
            Text("hi")
        }
    }
}
