//
//  HaruApp.swift
//  Haru
//
//  Created by 최정민 on 2023/03/25.
//

import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("[Debug] 알림 권한 획득")
                Global.scheduleNotification(title: "테스트", body: "테스트", year: 2023, month: 5, day: 29, hour: 17, minute: 35, identifier: "haru-test")
            } else {
                print("[Debug] 알림 권한 거부")
            }
        }

        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void
    ) {
        completionHandler([.banner, .list])
    }
}

@main
struct HaruApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var global: Global = .shared

    init() {
        print(UIDevice.current.name)
        // Kakao SDK 초기화
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        KakaoSDK.initSDK(appKey: kakaoAppKey as! String)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(global)
                .onOpenURL { url in
                    // Handle the URL callback from KakaoTalk login
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }
}
