//
//  FallowView.swift
//  Haru
//
//  Created by 이준호 on 2023/05/02.
//

import SwiftUI

struct FallowView: View {
    @State var isFallowing: Bool = true

    @State var searchWord: String = ""
    
    @State var fallowingModalVis: Bool = false
    @State var fallowerModalVis: Bool = false
    
    var fallowingCnt: Int = 5
    var fallowerCnt: Int = 10
    
    var body: some View {
        ZStack {
            VStack(spacing: 15) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("팔로윙")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFallowing ? .gradientStart1 : .mainBlack)
                            .onTapGesture {
                                withAnimation {
                                    isFallowing = true
                                }
                            }
                        
                        Text("팔로워")
                            .frame(width: 175, height: 20)
                            .font(.pretendard(size: 14, weight: .bold))
                            .foregroundColor(isFallowing ? .mainBlack : .gradientStart1)
                            .onTapGesture {
                                withAnimation {
                                    isFallowing = false
                                }
                            }
                    }
                    
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(.gray4)
                            .frame(width: 175 * 2, height: 4)
                        
                        Rectangle()
                            .fill(.gradation2)
                            .frame(width: 175, height: 4)
                            .offset(x: isFallowing ? 0 : 175)
                    }
                }
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.template)
                        .foregroundColor(.gray2)
                        .fontWeight(.bold)
                    TextField("검색어를 입력하세요", text: $searchWord)
                        .foregroundColor(.gray2)
                }
                .padding(.all, 10)
                .background(Color(0xf1f1f5))
                .cornerRadius(15)
                .padding(.horizontal, 20)
                
                ScrollView {
                    LazyVStack(spacing: 30) {
                        ForEach(0 ... (isFallowing ? fallowingCnt : fallowerCnt), id: \.self) { _ in
                            HStack(spacing: 16) {
                                ProfileImgView(imageUrl: URL(string: "https://item.kakaocdn.net/do/fd0050f12764b403e7863c2c03cd4d2d7154249a3890514a43687a85e6b6cc82")!)
                                    .frame(width: 30, height: 30)
                                
                                Text("게으름민수")
                                    .font(.pretendard(size: 16, weight: .bold))
                                Spacer()
                                Button {
                                    if isFallowing {
                                        withAnimation {
                                            fallowingModalVis = true
                                        }
                                    } else {
                                        withAnimation {
                                            fallowerModalVis = true
                                        }
                                    }
                                } label: {
                                    Image("ellipsis")
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                } // Scroll
            } // VStack
            
            if fallowingModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            fallowingModalVis = false
                        }
                    }

                Modal(isActive: $fallowingModalVis, ratio: 0.4) {
                    Text("팔로윙 하시겠습니까?")
                }
                .transition(.modal)
                .zIndex(2)
            }
            
            if fallowerModalVis {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .zIndex(1)
                    .onTapGesture {
                        withAnimation {
                            fallowerModalVis = false
                        }
                    }

                Modal(isActive: $fallowerModalVis, ratio: 0.4) {
                    Text("팔로워를 삭제 하시겠습니까?")
                }
                .transition(.modal)
                .zIndex(2)
            }
        } // ZStack
    }
}

struct FallowView_Previews: PreviewProvider {
    static var previews: some View {
        FallowView()
    }
}
