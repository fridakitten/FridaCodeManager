//
//  Created by Artem Novichkov on 20.05.2021.
//

import SwiftUI

struct NamePopupView: View {
    
    @Binding var isPresented: Bool
    @Binding var inputtext: String
    @Binding var showGit: Bool
    @Binding var pck: String
    
    var body: some View {
     ZStack {
        /*FluidGradient(blobs: [.orange, .primary, .yellow],
                      highlights: [.orange, .primary, .yellow],
                      speed: 1.0,
                      blur: 0.75)
          .ignoresSafeArea()
          .frame(height: 220)
          .background(.quaternary)*/
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("GitHub URL")
                    .font(.system(size: 25, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    isPresented = false
                }, label: {
                    Image(systemName: "xmark")
                        .imageScale(.small)
                        .frame(width: 32, height: 32)
                        .background(Color.black.opacity(0.06))
                        .cornerRadius(16)
                        .foregroundColor(.primary)
                })
            }
            TextField("Link", text: $inputtext)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false
                    showGit = true
                }, label: {
                    Text("Submit")
                })
                .frame(width: 80, height: 36)
                .background(Color(.systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
        .padding()
    }
  }
}