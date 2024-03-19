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