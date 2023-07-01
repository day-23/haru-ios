//
//  CameraView.swift
//  Haru
//
//  Created by 이준호 on 2023/06/17.
//

import PhotosUI
import SwiftUI

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Binding var isPopup: Bool // fullScreenOver를 닫기 위해서는 false로 변경 시켜주기
    @Binding var requestPermission: Bool

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { grated in
                if grated {
                    print("[Debug] 카메라 권한 허용")
                } else {
                    isPopup = false
                }
            }
        case .restricted, .denied:
            requestPermission = true
        case .authorized:
            print("[Debug] 카메라 권한 획득")
        @unknown default:
            fatalError()
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(image: $image)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        @Binding var image: UIImage?

        init(image: Binding<UIImage?>) {
            _image = image
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let selectedImage = info[.originalImage] as? UIImage {
                image = selectedImage
            }
            picker.dismiss(animated: true, completion: nil)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
