 /* 
 UIIconSetter.swift 

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

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePickerView

        init(parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage.scaleToSize(size: CGSize(width: 1024, height: 1024))
            }

            parent.presentationMode.wrappedValue.dismiss()
        }
    }

    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension ImagePickerView {
    func scaleImage(image: UIImage, toSize size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension UIImage {
    func scaleToSize(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

struct ImgView: View {
    @State var projpath: String
    @State var selectedImage: UIImage?
    @State var isImagePickerPresented: Bool = false
    @State var imageloaded: Bool = false
    @Binding var iconid: UUID

    var body: some View {
            Section(header: Text("icon")) {
            if let image = selectedImage {
                HStack {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(25)
                Spacer()
                }
                
                Button("Assign Icon") {
                    saveImage(image)
                    iconid = UUID()
                }
            } else {
                Text("App does not have a Icon")
            }

            Button("Add Icon") {
imageloaded = true
                self.isImagePickerPresented.toggle()
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(selectedImage: $selectedImage)
            }
        }
            if fe("\(projpath)/Resources/AppIcon.png") {
                Section {
                    Button("Remove Icon") {
                        remove()
                        iconid = UUID()
                    }
                    .accentColor(Color.red)
                }
                .onAppear {
                    if imageloaded == false {
                        selectedImage = loadImage(fromPath: "\(projpath)/Resources/AppIcon.png")
                    }
                }
            }
    }
    
    func saveImage(_ image: UIImage) {
        guard let imageData = image.pngData() else {
            return
        }

        let fileURL = URL(fileURLWithPath: projpath).appendingPathComponent("Resources").appendingPathComponent("AppIcon.png")

        do {
            try imageData.write(to: fileURL)
            wplist(value: "AppIcon.png", forKey: "CFBundleIconFile", plistPath: "\(projpath)/Resources/Info.plist")
            print("Image saved successfully at: \(fileURL)")
        } catch {
            print("Error saving image: \(error.localizedDescription)")
        }
    }
    func remove() {
        if fe("\(projpath)/Resources/AppIcon.png") {
            rmplist(key: "CFBundleIconFile", plistPath: "\(projpath)/Resources/Info.plist")
            removeFile(atPath: "\(projpath)/Resources/AppIcon.png")
            selectedImage = createEmptyImage()
        }
    }
    func removeFile(atPath filePath: String) {
    do {
        try FileManager.default.removeItem(atPath: filePath)
        print("File at \(filePath) removed successfully.")
    } catch {
        print("Error: Unable to remove file at \(filePath). \(error.localizedDescription)")
    }
}
}

func loadImage(fromPath imagePath: String) -> UIImage? {
    if let image = UIImage(contentsOfFile: imagePath) {
        return image
    } else {
        print("Error: Unable to load image from \(imagePath)")
        return nil
    }
}

func createEmptyImage() -> UIImage? {
    let size = CGSize(width: 0, height: 0)
    UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
    defer { UIGraphicsEndImageContext() }
    
    if let emptyImage = UIGraphicsGetImageFromCurrentImageContext() {
        return emptyImage
    } else {
        return nil
    }
}