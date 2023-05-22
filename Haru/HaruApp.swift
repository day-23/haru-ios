//
//  HaruApp.swift
//  Haru
//
//  Created by 최정민 on 2023/03/25.
//
import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI

@main
struct HaruApp: App {
    init() {
        // Kakao SDK 초기화
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: kakaoAppKey as! String)
    }

    var body: some Scene {
        WindowGroup {
            RootView().onOpenURL { url in
                // Handle the URL callback from KakaoTalk login
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                }
            }
        }
    }
}
