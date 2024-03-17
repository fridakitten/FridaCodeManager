//
//  Created by Artem Novichkov on 20.05.2021.
//

import SwiftUI

struct ProjPopupView: View {
    @Binding var isPresented: Bool
    @Binding var AppName: String
    @Binding var BundleID: String
    @Binding var SDK: String
    @Binding var hellnah: UUID
    @State private var type = 1
    var body: some View {
     ZStack {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Create Project")
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
            TextField("Application Name", text: $AppName)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
            TextField("Bundle Identifier", text: $BundleID)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
            HStack {
                HStack {
                Spacer().frame(width: 10)
                Text("Scheme")
                    .foregroundColor(.primary)
                Spacer()
                VStack {
                Picker("" ,selection: $type) {
                    Text("Swift App").tag(1)
                    Text("ObjC App").tag(2)
                    Text("Swift/ObjC App").tag(3)
            }
            .pickerStyle(MenuPickerStyle())
                    }
                Spacer()
                }
                .frame(height: 36)
                .background(Color(.systemBackground).opacity(0.5))
                .foregroundColor(.primary)
                .accentColor(.secondary)
                .cornerRadius(10)
                Spacer().frame(width: 10)
                Button(action: {
                    let docs = "\(docsDir())/\(AppName)"
                    if AppName != "" {
                    if BundleID != "" {
                    if !fe(docs) {
isPresented = false
                    MakeApplicationProject(AppName, BundleID,SDK: SDK, type: type)
AppName = ""
BundleID = ""
hellnah = UUID()
                            }
                        }
                    }
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