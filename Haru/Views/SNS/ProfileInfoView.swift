//
//  ProfileInfoView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/04.
//

import SwiftUI

struct ProfileInfoView: View {
    @State private var isFeedSelected: Bool = true

    @StateObject var snsVM: SNSViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let imageURL = snsVM.myProfileURL {
                    ProfileImgView(imageUrl: imageURL)
                        .frame(width: 62, height: 62)
                } else {
                    Image(systemName: "person")
                        .clipShape(Circle())
                        .frame(width: 62, height: 62)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("게으름민수")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("노는게 제일 좋아")
                        .font(.pretendard(size: 14, weight: .regular))
                }

                Spacer()

                VStack(spacing: 4) {
                    NavigationLink {
                        ProfileFormView(snsVM: snsVM)
                    } label: {
                        Text("프로필 편집")
                            .foregroundColor(.mainBlack)
                            .font(.pretendard(size: 14, weight: .bold))
                            .frame(width: 64, height: 16)
                            .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                            .overlay(
                                RoundedRectangle(cornerRadius: 9)
                                    .stroke(.gradation2, lineWidth: 1)
                            )
                    }
                    Text("프로필 공유")
                        .font(.pretendard(size: 14, weight: .bold))
                        .frame(width: 64, height: 16)
                        .padding(EdgeInsets(top: 5, leading: 11, bottom: 5, trailing: 11))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .stroke(.gradation2, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 20)

            Spacer()
                .frame(height: 20)

            HStack {
                Spacer()
                VStack {
                    Text("2")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("하루")
                        .font(.pretendard(size: 14, weight: .regular))
                }
                Spacer()
                VStack {
                    Text("25")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("팔로우")
                        .font(.pretendard(size: 14, weight: .regular))
                }
                Spacer()
                VStack {
                    Text("10")
                        .font(.pretendard(size: 20, weight: .bold))
                    Text("팔로워")
                        .font(.pretendard(size: 14, weight: .regular))
                }
                Spacer()
            }

            Spacer()
                .frame(height: 20)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("내 피드")
                        .frame(width: 175, height: 20)
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(isFeedSelected ? .gradientStart1 : .mainBlack)
                        .onTapGesture {
                            withAnimation {
                                isFeedSelected = true
                            }
                        }

                    Text("미디어")
                        .frame(width: 175, height: 20)
                        .font(.pretendard(size: 14, weight: .bold))
                        .foregroundColor(isFeedSelected ? .mainBlack : .gradientStart1)
                        .onTapGesture {
                            withAnimation {
                                isFeedSelected = false
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
                        .offset(x: isFeedSelected ? 0 : 175)
                }
            }

            if isFeedSelected {
                Spacer()
                    .frame(height: 20)
                FeedListView(snsVM: snsVM, feedList: $snsVM.myFeedList)
            } else {
                MediaView()
            }
        }
    }
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInfoView(snsVM: SNSViewModel())
    }
}
