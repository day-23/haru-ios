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
            insertion: .push(from: .bottom),
            removal: .push(from: .top)
        )
    }

    static var picker: AnyTransition {
        .asymmetric(
            insertion: .push(from: .bottom),
            removal: .push(from: .top)
        )
    }
}
