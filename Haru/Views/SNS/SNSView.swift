//
//  SNSView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct Sns: Identifiable, Hashable {
    let id: String = UUID().uuidString
    let imageURL: URL
    let isLike: Bool
}

struct SNSView: View {
    let snsContents = [
        Sns(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true),
        
        Sns(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: false),
        
        Sns(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: false),
        
        Sns(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true),
        
        Sns(imageURL: URL(string: "https://cloudfront-ap-northeast-1.images.arcpublishing.com/chosun/CYNMM4A3LOWZ44ZLGRZI3VBAZE.png")!, isLike: true)
    ]
    
    @State private var maxNumber: Int = 4
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(0 ... maxNumber, id: \.self) { num in
                        VStack(spacing: 16) {
                            HStack {
                                ProfileImgView(imageUrl: URL(string: "https://item.kakaocdn.net/do/fd0050f12764b403e7863c2c03cd4d2d7154249a3890514a43687a85e6b6cc82")!)
                                Text("게으름민수")
                                    .font(.pretendard(size: 14, weight: .bold))
                                    .foregroundColor(.mainBlack)
                                Text("1일 전")
                                    .font(.pretendard(size: 10, weight: .regular))
                                    .foregroundColor(.gray2)
                                Spacer()
                                Image("ellipsis")
                                    .renderingMode(.template)
                                    .foregroundColor(.gray1)
                            }
                            .padding(.horizontal, 20)
                            
                            AsyncImage(url: snsContents[num % 5].imageURL) { image in
                                image
                                    .resizable()
                            } placeholder: {
                                Image(systemName: "wifi.slash")
                            }
                            .frame(width: 395, height: 390)
                            .onAppear {
                                if num % 5 == 4 {
                                    maxNumber += 5
                                }
                            }
                            
                            HStack(spacing: 22) {
                                Image(systemName: snsContents[num % 5].isLike ? "heart.fill" : "heart")
                                    .foregroundColor(.red)
                                Image(systemName: "ellipses.bubble")
                                    .foregroundColor(.gray2)
                                Spacer()
                                Image("option-button")
                                    .renderingMode(.template)
                                    .foregroundColor(.gray2)
                            }
                            .padding(.horizontal, 20)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

struct SNSView_Previews: PreviewProvider {
    static var previews: some View {
        SNSView()
    }
}
