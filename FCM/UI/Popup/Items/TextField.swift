import SwiftUI

public struct POTextField: View {
    var title: String
    @Binding var content: String
    public var body: some View {
        TextField(title, text: $content)
            .frame(height: 36)
            .padding([.leading, .trailing], 10)
            .background(Color(.systemBackground).opacity(0.7))
            .cornerRadius(10)
            .disableAutocorrection(true)
            .autocapitalization(.none)
    }
}
