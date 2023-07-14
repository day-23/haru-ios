//
//  MediaView.swift
//  Haru
//
//  Created by 이준호 on 2023/04/05.
//

import Kingfisher
import SwiftUI

struct MediaView: View {
    var url: URL?

    var body: some View {
        let width = (UIScreen.main.bounds.size.width - 6) / 3
        if let url {
            KFImage(url)
                .downsampling(size: CGSize(width: width * UIScreen.main.scale, height: width * UIScreen.main.scale))
                .placeholder { _ in
                    ProgressView()
                }
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
