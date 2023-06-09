//
//  InformationView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/26.
//

import SwiftUI

struct InformationView: View {
    @Environment(\.dismiss) var dismissAction

    var body: some View {
        VStack(spacing: 0) {
            SettingHeader(header: "정보") {
                dismissAction.callAsFunction()
            }

            Divider()
                .padding(.top, 19)
                .padding(.bottom, 20)

            VStack(spacing: 8) {
                InformationRow(content: "이용 약관") {}
                Divider().padding(.bottom, 6)

                InformationRow(content: "개인정보 정책") {}
                Divider().padding(.bottom, 6)

                InformationRow(content: "오픈 소스") {}
                Divider().padding(.bottom, 6)
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}

struct InformationRow<Destination: View>: View {
    var content: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack(spacing: 0) {
                Text(content)
                    .font(.pretendard(size: 16, weight: .regular))
                    .foregroundColor(Color(0x191919))
                    .padding(.leading, 14)

                Spacer()

                Image("setting-detail-button")
                    .frame(width: 28, height: 28)
            }
        }
    }
}

struct InformationView_Previews: PreviewProvider {
    static var previews: some View {
        InformationView()
    }
}
