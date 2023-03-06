//
//  AnyTransition.swift
//  Haru
//
//  Created by 최정민 on 2023/03/07.
//

import Foundation
import SwiftUI

extension AnyTransition {
    static var modal: AnyTransition {
        .asymmetric(
            insertion: .push(from: .bottom).combined(with: .opacity),
            removal: .push(from: .top).combined(with: .opacity)
        )
    }
}
