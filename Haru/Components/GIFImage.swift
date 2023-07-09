//
//  GIFImage.swift
//  Haru
//
//  Created by 이준호 on 2023/07/07.
//

import FLAnimatedImage
import SwiftUI

struct GifImage: UIViewRepresentable {
    private let url: String
    private let data: Data?
    
    init(url: String, data: Data?) {
        self.url = url
        self.data = data
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        view.addSubview(activityIndicator)
        view.addSubview(imageView)
        
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        activityIndicator.startAnimating()
        
        guard let url = URL(string: url) else { return }
        DispatchQueue.global().async {
            if let data {
                let image = FLAnimatedImage(animatedGIFData: data)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    imageView.animatedImage = image
                }
            } else if let animatedGIFData = try? Data(contentsOf: url) {
                let image = FLAnimatedImage(animatedGIFData: animatedGIFData)
                DispatchQueue.main.async {
                    activityIndicator.stopAnimating()
                    imageView.animatedImage = image
                }
            }
        }
    }
    
    private let imageView: FLAnimatedImageView = {
        let imageView = FLAnimatedImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .gray
        return activityIndicator
    }()
}
