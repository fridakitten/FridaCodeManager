import SwiftUI

struct POTextField: View {
    var title: String
    @Binding var content: String
    var body: some View {
        TextField(title, text: $content)
            .frame(height: 36)
            .padding([.leading, .trailing], 10)
            .cornerRadius(10)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}
