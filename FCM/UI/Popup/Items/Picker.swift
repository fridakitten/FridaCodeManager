import SwiftUI

public struct PickerItems: Identifiable {
    public let id: Int
    public let name: String
}

public struct POPicker: View {
    let function: () -> Void

    var title: String
    var items: [PickerItems]
    @Binding var type: Int
    
    public var body: some View  {
        HStack {
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $type) {
                        ForEach(items) { item in
                            Text(item.name).tag(item.id)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
            }
            .frame(height: 36)
            .background(Color(UIColor.systemGray5))
            .foregroundColor(.primary)
            .accentColor(.secondary)
            .cornerRadius(10)

            Spacer()
            
            Button(action: {
                function()
            }, label: {
                Text("Submit")
                    .frame(width: 80, height: 36)
                    .background(Color(UIColor.systemGray5))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            })
        }
        .frame(height: 36)
    }
}

