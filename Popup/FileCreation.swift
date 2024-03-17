import SwiftUI

struct CreatePopupView: View {
    @Binding var isPresented: Bool
    @Binding var filepath: String
    @State private var FileName: String = ""
    @State private var type = 1
    var body: some View {
     ZStack {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Create")
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
            TextField("Name", text: $FileName)
                .frame(height: 36)
                .padding([.leading, .trailing], 10)
                .background(Color(.systemBackground).opacity(0.5))
                .cornerRadius(10)
            HStack {
                HStack {
                Spacer().frame(width: 10)
                Text("Type")
                    .foregroundColor(.primary)
                Spacer()
                VStack {
                Picker("" ,selection: $type) {
                    Text("File").tag(1)
                    Text("Folder").tag(2)
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
                    if FileName != "" {
                        if type == 1 {
cfile(atPath: "\(filepath)/\(FileName)", withContent: "")
                        } else if type == 2 {
                            cfolder(atPath: "\(filepath)/\(FileName)")
                        }
                        FileName = ""
                        isPresented = false
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