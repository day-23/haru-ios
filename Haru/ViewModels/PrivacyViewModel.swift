//
//  PrivacyViewModel.swift
//  Haru
//
//  Created by 최정민 on 12/16/23.
//

import Foundation
import SwiftUI

final class PrivacyViewModel: ObservableObject {
    private static func getAllowStatusString(status: Int) -> String {
        switch status {
        case 0:
            return "허용 안함"
        case 1:
            return "친구만"
        case 2:
            return "모든 사람"
        default:
            return "허용 안함"
        }
    }

    private static func getAllowStatusCode(status: String) -> Int {
        switch status {
        case "허용 안함":
            return 0
        case "친구만":
            return 1
        case "모든 사람":
            return 2
        default:
            return 0
        }
    }

    @Published private var _isPublicAccount: Bool
    var isPublicAccount: Bool {
        get {
            return _isPublicAccount
        }
        set(value) {
            _isPublicAccount = value
            Global.shared.user?.user.isPublicAccount = !value
            UserService.updateUserOption(isPublicAccount: !value) { _ in }
        }
    }

    @Published private var _isPostBrowsingEnabled: Bool
    var isPostBrowsingEnabled: Bool {
        get {
            return _isPostBrowsingEnabled
        }
        set(value) {
            _isPostBrowsingEnabled = value
            Global.shared.user?.isPostBrowsingEnabled = value
            UserService.updateUserOption(isPostBrowsingEnabled: value) { _ in }
        }
    }

    @Published private var _isAllowFeedLike: String
    var isAllowFeedLike: String {
        get {
            return _isAllowFeedLike
        }
        set(value) {
            _isAllowFeedLike = value
            let statusCode = PrivacyViewModel.getAllowStatusCode(status: value)
            Global.shared.user?.isAllowFeedLike = statusCode
            UserService.updateUserOption(isAllowFeedLike: statusCode) { _ in }
        }
    }

    @Published private var _isAllowFeedComment: String
    var isAllowFeedComment: String {
        get {
            return _isAllowFeedComment
        }
        set(value) {
            _isAllowFeedComment = value
            let statusCode = PrivacyViewModel.getAllowStatusCode(status: value)
            Global.shared.user?.isAllowFeedComment = statusCode
            UserService.updateUserOption(isAllowFeedComment: statusCode) { _ in }
        }
    }

    @Published private var _isAllowSearch: Bool
    var isAllowSearch: Bool {
        get {
            return _isAllowSearch
        }
        set(value) {
            _isAllowSearch = value
            Global.shared.user?.isAllowSearch = value
            UserService.updateUserOption(isAllowSearch: value) { _ in }
        }
    }

    init() {
        guard let user = Global.shared.user else {
            self._isPublicAccount = false
            self._isPostBrowsingEnabled = false
            self._isAllowFeedLike = "허용 안함"
            self._isAllowFeedComment = "허용 안함"
            self._isAllowSearch = false
            return
        }

        self._isPublicAccount = user.user.isPublicAccount
        self._isPostBrowsingEnabled = user.isPostBrowsingEnabled
        self._isAllowFeedLike = PrivacyViewModel.getAllowStatusString(status: user.isAllowFeedLike)
        self._isAllowFeedComment = PrivacyViewModel.getAllowStatusString(status: user.isAllowFeedComment)
        self._isAllowSearch = user.isAllowSearch
    }
}
