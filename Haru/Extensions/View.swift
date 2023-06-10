//
//  View.swift
//  Haru
//
//  Created by 이준호 on 2023/03/14.
//  Updated by 최정민 on 2023/03/27.
//

import Photos
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func placeholder(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> some View
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension View {
    @ViewBuilder
    func popover(isPresented: Binding<Bool>, arrowDirection: UIPopoverArrowDirection, @ViewBuilder content: @escaping () -> some View) -> some View {
        background {
            PopOverController(isPresented: isPresented, arrowDirection: arrowDirection, content: content())
        }
    }
}

extension View {
    func customNavigationBar(
        centerView: @escaping (() -> some View),
        leftView: @escaping (() -> some View),
        rightView: @escaping (() -> some View)
    ) -> some View {
        modifier(
            CustomNavBar(centerView: centerView, leftView: leftView, rightView: rightView)
        )
    }

    func customNavigationBar(
        leftView: @escaping (() -> some View),
        rightView: @escaping (() -> some View)
    ) -> some View {
        modifier(
            CustomNavBar(centerView: { EmptyView() }, leftView: leftView, rightView: rightView)
        )
    }
}

struct PopOverController<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var arrowDirection: UIPopoverArrowDirection
    var content: Content

    @State private var alreadyPresented: Bool = false

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if alreadyPresented {
            if !isPresented {
                uiViewController.dismiss(animated: true) {
                    alreadyPresented = false
                }
            }
        } else {
            if isPresented {
                let controller = CustomHostingView(rootView: content)
                controller.view.backgroundColor = .systemBackground
                controller.modalPresentationStyle = .popover
                controller.popoverPresentationController?.permittedArrowDirections = arrowDirection
                controller.presentationController?.delegate = context.coordinator
                controller.popoverPresentationController?.sourceView = uiViewController.view

                uiViewController.present(controller, animated: true)
            }
        }
    }

    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        var parent: PopOverController
        init(parent: PopOverController) {
            self.parent = parent
        }

        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }

        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            parent.isPresented = false
        }

        func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
            DispatchQueue.main.async {
                self.parent.alreadyPresented = true
            }
        }
    }
}

class CustomHostingView<Content: View>: UIHostingController<Content> {
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = view.intrinsicContentSize
    }
}

extension View {
    @ViewBuilder
    func popupImagePicker(show: Binding<Bool>, transition: AnyTransition = .move(edge: .bottom), mode: ImagePickerMode = .multiple, always: Bool = false, onSelect: @escaping ([PHAsset]) -> Void) -> some View {
        overlay {
            let deviceSize = UIScreen.main.bounds.size
            ZStack {
                // MARK: BG Blur

                if !always {
                    Rectangle()
                        .fill(.black)
                        .ignoresSafeArea()
                        .opacity(show.wrappedValue ? 0.4 : 0)
                        .onTapGesture {
                            show.wrappedValue = false
                        }
                }

                if show.wrappedValue {
                    PopupImagePicker(mode: mode) {
                        show.wrappedValue = false
                    } onSelect: { assets in
                        onSelect(assets)
                        if !always {
                            show.wrappedValue = false
                        }
                    }
                    .transition(transition)
                }
            }
            .frame(width: deviceSize.width, height: deviceSize.height)
            .animation(.easeInOut, value: show.wrappedValue)
        }
    }
}

#if os(macOS)
extension View {
    func whenHovered(_ mouseIsInside: @escaping (Bool) -> Void) -> some View {
        modifier(MouseInsideModifier(mouseIsInside))
    }
}
#endif
