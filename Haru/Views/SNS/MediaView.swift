//
//  MediaView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import SwiftUI

struct MediaView: View {
    var uiImage: UIImage?

    var body: some View {
        let width = (UIScreen.main.bounds.size.width - 6) / 3
        if let uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .frame(width: width, height: width)
        } else {
            ProgressView()
                .frame(width: width, height: width)
        }
    }
}

// struct MediaView_Previews: PreviewProvider {
//    static var previews: some View {
//        MediaView()
//    }
// }
