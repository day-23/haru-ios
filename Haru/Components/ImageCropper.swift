//
//  ImageCropper.swift
//  Haru
//
//  Created by 이준호 on 2023/06/13.
//

import Mantis
import SwiftUI

struct ImageCropper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var cropShapeType: Mantis.CropShapeType
    @Binding var presetFixedRatioType: Mantis.PresetFixedRatioType
    
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: CropViewControllerDelegate {
        var parent: ImageCropper
        
        init(_ parent: ImageCropper) {
            self.parent = parent
        }
        
        func cropViewControllerDidCrop(_ cropViewController: Mantis.CropViewController, cropped: UIImage, transformation: Transformation, cropInfo: CropInfo) {
            parent.image = cropped
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func cropViewControllerDidCancel(_ cropViewController: Mantis.CropViewController, original: UIImage) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return makeImageCropperHiddingRotationDial(context: context)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

extension ImageCropper {
    func makeImageCropperHiddingRotationDial(context: Context) -> UIViewController {
        var config = Mantis.Config()
        config.cropViewConfig.showAttachedRotationControlView = false
        config.presetFixedRatioType = presetFixedRatioType
        let cropViewController = Mantis.cropViewController(image: image!, config: config)
        cropViewController.delegate = context.coordinator

        return cropViewController
    }
}
