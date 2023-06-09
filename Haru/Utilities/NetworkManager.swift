//
//  NetworkManager.swift
//  Haru
//
//  Created by 최정민 on 2023/06/09.
//

import Foundation
import Network

final class NetworkManager {
    static let shared = NetworkManager()
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected: Bool = false
    public private(set) var connectionType: ConnectionType = .unknown

    // 연결타입
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        monitor = NWPathMonitor()
    }

    func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.getConnectionType(path)

                if self?.isConnected == true {
                    // 네트워크 연결 OK
                    Global.shared.isNetworkConnected = true
                } else {
                    Global.shared.isNetworkConnected = false
                }
            }
        }
    }

    public func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
