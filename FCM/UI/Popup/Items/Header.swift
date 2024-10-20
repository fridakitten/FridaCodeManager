import SwiftUI

public struct POHeader: View {
    var title: String

    public var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
