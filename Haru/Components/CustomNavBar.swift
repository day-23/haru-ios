//
//  CustomNavBar.swift
//  Haru
//
//  Created by 이준호 on 2023/05/03.
//

 import SwiftUI

 struct CustomNavBar<C,L,R>: ViewModifier where C: View, L: View, R: View {
    let centerView: (() -> C)?
    let leftView: (() -> L)?
    let rightView: (() -> R)?

    init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
    }

     func body(content: Content) -> some View {
         VStack(spacing: 0) {
             ZStack {
                 LinearGradient(
                    colors: [.gradientStart2, .gradientEnd2],
                    startPoint: .leading,
                    endPoint: .trailing
                 )
                 .ignoresSafeArea(.all)
                 
                 HStack {
                     self.leftView?()
                     
                     Spacer()
                     
                     self.rightView?()
                 }
                 .padding(.horizontal, 20)
                 
                 HStack {
                     Spacer()
                     
                     self.centerView?()
                     
                     Spacer()
                 }
             }
             .frame(height: 52)
             
             content
             
             Spacer()
         }
         .toolbar(.hidden)
    }
 }
