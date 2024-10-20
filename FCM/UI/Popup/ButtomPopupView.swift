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
 */

import SwiftUI

struct BottomPopupView<Content: View>: View {
    let content: Content

    @State private var keyboardHeight: CGFloat = 0
    @State private var isKeyboardVisible: Bool = false
    @State private var addition: CGFloat = 25
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
                        FluidGradient(blobs: [.green, .primary, .gray],
                                 highlights: [.green, .primary, .gray],
                                                            speed: 0.25,
                                                            blur: 0.75)
                            .ignoresSafeArea()
                            .background(.quaternary)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(radius: 16, corners: [.topLeft, .topRight])
                    .cornerRadius(radius: corner_addition, corners: [.bottomLeft, .bottomRight])
                    .offset(y: isKeyboardVisible ? -keyboardHeight : 0)
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
                        addition = 25
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
