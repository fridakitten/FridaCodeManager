import SwiftUI

struct POButtonBar: View {
    let cancel: () -> Void
    let confirm: () -> Void
    var body: some View {
        HStack {
            Button(action: {
                cancel()
            }, label: {
                Text("Cancel")
            })
            .frame(width: 80, height: 36)
            .background(Color(.systemBackground).opacity(0.7))
            .foregroundColor(.primary)
            .cornerRadius(10)
            Spacer()
            Button(action: {
                confirm()
            }, label: {
                Text("Confirm")
            })
            .frame(width: 80, height: 36)
            .background(Color(.systemBackground).opacity(0.7))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
    }
}
