import SwiftUI

public struct POSchemePicker: View {
    let function: () -> Void
    @Binding var type: Int
    
    public var body: some View  {
        HStack {
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Scheme")
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $type) {
                        #if jailbreak
                        Text("Swift App").tag(1)
                        #endif
                        Text("ObjC App").tag(2)
                        #if jailbreak
                        Text("Swift/ObjC App").tag(3)
                        #endif
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

