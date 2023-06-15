//
//  LoadingView.swift
//  Haru
//
//  Created by 최정민 on 2023/06/09.
//

import SwiftUI

final class WaterTimer: ObservableObject {
    @Published var index: Int

    let end: Int = 9

    init(index: Int = 0) {
        self.index = index

        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.index += 1
            self.index %= self.end
        }
    }
}

struct LoadingView: View {
    @StateObject private var waterTimer: WaterTimer = .init()
    @State private var isDrop = false

    var body: some View {
        ZStack {
            Color(0x191919, opacity: 0.5)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                Spacer()

                Image("loading-water-\(waterTimer.index)")

                Spacer(minLength: 180)
                    .overlay {
                        VStack {
                            Image("loading-water-drop")
                                .offset(y: isDrop ? 160 : 0)
                                .animation(.spring(), value: isDrop)
                                .opacity(waterTimer.index == waterTimer.end - 1 ? 1 : 0)

                            Spacer()
                        }
                    }

                Image("loading-rock")

                Spacer(minLength: 73)

                Text("로딩 중입니다")
                    .font(.pretendard(size: 16, weight: .bold))
                    .foregroundColor(Color(0xfdfdfd))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(0xdbdbdb, opacity: 0.5))
                    .cornerRadius(10)

                Spacer()
            }
            .onChange(of: waterTimer.index) {
                if $0 == waterTimer.end - 1 {
                    isDrop = true
                } else {
                    isDrop = false
                }
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
