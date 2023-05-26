//
//  BlackTransparentView.swift
//  Haru
//
//  Created by 최정민 on 2023/05/27.
//

import SwiftUI

struct CenteredLoadingView<RootView: View>: View {
    private let rootView: RootView
    @Binding var isActive: Bool

    init(rootView: RootView, isActive: Binding<Bool>) {
        self.rootView = rootView
        self._isActive = isActive
    }

    var body: some View {
        rootView
            .background(Activator(showLoading: $isActive))
    }

    struct Activator: UIViewRepresentable {
        @Binding var showLoading: Bool
        @State private var myWindow: UIWindow? = nil

        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            DispatchQueue.main.async {
                self.myWindow = view.window
            }
            return view
        }

        func updateUIView(_ uiView: UIView, context: Context) {
            guard let holder = myWindow?.rootViewController?.view else { return }

            if showLoading && context.coordinator.controller == nil {
                context.coordinator.controller = UIHostingController(rootView: loadingView)

                let view = context.coordinator.controller!.view
                view?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                view?.translatesAutoresizingMaskIntoConstraints = false
                holder.addSubview(view!)
                holder.isUserInteractionEnabled = false

                view?.leadingAnchor.constraint(equalTo: holder.leadingAnchor).isActive = true
                view?.trailingAnchor.constraint(equalTo: holder.trailingAnchor).isActive = true
                view?.topAnchor.constraint(equalTo: holder.topAnchor).isActive = true
                view?.bottomAnchor.constraint(equalTo: holder.bottomAnchor).isActive = true
            } else if !showLoading {
                context.coordinator.controller?.view.removeFromSuperview()
                context.coordinator.controller = nil
                holder.isUserInteractionEnabled = true
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator()
        }

        class Coordinator {
            var controller: UIViewController?
        }

        private var loadingView: some View {
            VStack {
                Color.white
                    .frame(width: 48, height: 72)
                Text("Loading")
                    .foregroundColor(.white)
            }
            .frame(width: 142, height: 142)
            .background(Color.primary.opacity(0.7))
            .cornerRadius(10)
        }
    }
}
