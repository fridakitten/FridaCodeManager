 /*
 ButtomPopupView.swift

 Copyright (C) 2023, 2024 SparkleChan and SeanIsTethered
 Copyright (C) 2024 fridakitten

 This file is part of FridaCodeManager.

 FridaCodeManager is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 FridaCodeManager is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with FridaCodeManager. If not, see <https://www.gnu.org/licenses/>.

  ______    _     _         _____        __ _                           ______                    _       _   _
 |  ___|  (_)   | |       /  ___|      / _| |                          |  ___|                  | |     | | (_)
 | |_ _ __ _  __| | __ _  \ `--.  ___ | |_| |___      ____ _ _ __ ___  | |_ ___  _   _ _ __   __| | __ _| |_ _  ___  _ __
 |  _| '__| |/ _` |/ _` |  `--. \/ _ \|  _| __\ \ /\ / / _` | '__/ _ \ |  _/ _ \| | | | '_ \ / _` |/ _` | __| |/ _ \| '_ \
 | | | |  | | (_| | (_| | /\__/ / (_) | | | |_ \ V  V / (_| | | |  __/ | || (_) | |_| | | | | (_| | (_| | |_| | (_) | | | |
 \_| |_|  |_|\__,_|\__,_| \____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___| \_| \___/ \__,_|_| |_|\__,_|\__,_|\__|_|\___/|_| |_|
 Founded by. Sean Boleslawski, Benjamin Hornbeck and Lucienne Salim in 2023
 */

import SwiftUI

struct BottomPopupView<Content: View>: View {
    let content: Content

    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    @State private var addition: CGFloat = UIDevice.current.hasNotch ? 25.0 : 0.0
    @State private var corner_addition: CGFloat = 0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    content
                }
                .padding(20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + addition)
                    .background {
                        FluidGradient(blobs: [.purple, .primary, .pink],
                                 highlights: [.purple, .primary, .pink],
                                                            speed: 0.25,
                                                            blur: 0.75)
                            .ignoresSafeArea()
                            .background(.quaternary)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(isPad ? 16 : corner_addition)
                    .frame(width: isPad ? UIScreen.main.bounds.width / 2 : UIScreen.main.bounds.width - corner_addition * 2)
                    .offset(x: corner_addition , y: isKeyboardVisible ? -keyboardHeight : 0)
                    .animation(.easeInOut, value: keyboardHeight)
            }
            .edgesIgnoringSafeArea([.bottom])
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation(.easeOut(duration: 0.5)) {
                            addition = 0
                            corner_addition = 16
                            self.keyboardHeight = keyboardSize.height + 25
                            self.isKeyboardVisible = true
                        }
                    }
                }
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        if UIDevice.current.hasNotch {
                            addition = 25.0
                        }
                        corner_addition = 0
                        self.keyboardHeight = 0
                        self.isKeyboardVisible = false
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self)
            }
        }
        .transition(.move(edge: .bottom))
    }
}

extension UIDevice {
    var hasNotch: Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return false
        }
        let bottomInset = windowScene.windows.first?.safeAreaInsets.bottom ?? 0
        return bottomInset > 0
    }
}
