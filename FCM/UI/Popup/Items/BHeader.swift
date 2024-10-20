import SwiftUI

public struct POBHeader: View {
    @Binding var title: String

    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
