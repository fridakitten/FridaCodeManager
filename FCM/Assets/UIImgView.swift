 /* 
 UIImgView.swift 

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
import UIKit

struct PubImg: View {
    @State var projpath: String
    @State var selectedImage: UIImage?

    var body: some View {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .cornerRadius(10)
            } else {
                Rectangle()
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.primary, lineWidth: 2)
                   )
            }
            Spacer().frame(width: 0, height:0)
            .onAppear {
                if selectedImage == nil {
                    selectedImage = loadImage(fromPath: "\(projpath)/Resources/AppIcon.png")
                }
        }
    }
}
