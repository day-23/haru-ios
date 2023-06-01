//
//  KeyboardReadable.swift
//  Haru
//
//  Created by 이준호 on 2023/05/29.
//

import Combine
import Foundation
import UIKit

protocol KeyboardReadable {
    var keyboardEventPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    var keyboardEventPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}
