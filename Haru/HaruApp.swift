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
            } else {
                print("[Debug] 알림 권한 거부")
            }
        }

        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let identifier = notification.request.identifier
        if identifier == AlarmHelper.Regular.morning.rawValue {
            AlarmHelper.regularNotification(regular: .morning)
            return []
        } else if identifier == AlarmHelper.Regular.evening.rawValue {
            AlarmHelper.regularNotification(regular: .evening)
            return []
        }
        return [.banner, .list, .badge, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {}
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
                .onAppear {
                    AlarmHelper.scheduleRegularNotification(regular: .morning)
                    AlarmHelper.scheduleRegularNotification(regular: .evening)
                }
        }
    }
}
