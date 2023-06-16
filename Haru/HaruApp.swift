//
//  HaruApp.swift
//  Haru
//
//  Created by 최정민 on 2023/03/25.
//

import BackgroundTasks
import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        NetworkManager.shared.startMonitoring()
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "day23.haru.regular-alarm", using: nil) { task in
            self.scheduledNotificationAPI(task: task as! BGAppRefreshTask)
        }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
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
        return [.banner, .list, .badge, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {}

    func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }

    func scheduledNotificationAPI(task: BGAppRefreshTask) {
        // 다음 동작 수행, 반복시 필요
        scheduleAppRefresh()

        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }

        // 가벼운 백그라운드 작업 작성
        if let morning = Global.shared.user?.morningAlarmTime {
            AlarmHelper.createRegularNotification(regular: .morning, time: morning)
        }
        if let night = Global.shared.user?.nightAlarmTime {
            AlarmHelper.createRegularNotification(regular: .evening, time: night)
        }

        // setTaskCompleted는 무조건 호출되어야 함.
        task.setTaskCompleted(success: true)
    }

    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "day23.haru.regular-alarm")

        do {
            try BGTaskScheduler.shared.submit(request)
            // Set a breakpoint in the code that executes after a successful call to submit(_:).
        } catch {
            print("\(Date()): Could not schedule app refresh: \(error)")
        }
    }
}

@main
struct HaruApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
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
                .onChange(of: scenePhase) { phase in
                    switch phase {
                    case .active:
                        break
                    case .inactive:
                        break
                    case .background:
                        appDelegate.scheduleAppRefresh()
                    @unknown default:
                        break
                    }
                }
                .overlay {
                    VStack {
                        if global.isLoading {
                            LoadingView()
                                .zIndex(2)
                        } else if global.showGuestMessage {
                            Text("하루 애플리케이션을 둘러보세요")
                                .font(.pretendard(size: 16, weight: .bold))
                                .foregroundColor(Color(0x191919))
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .background(Color(0xdbdbdb, opacity: 0.5))
                                .cornerRadius(10)
                                .offset(y: UIScreen.main.bounds.height * 0.3)
                                .zIndex(2)
                        }
                    }
                }
        }
    }
}
