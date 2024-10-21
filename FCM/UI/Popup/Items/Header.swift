import SwiftUI

struct POHeader: View {
    var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct POBHeader: View {
    @Binding var title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 25, weight: .bold, design: .default))
                .foregroundColor(.primary)
            Spacer()
        }
    }
}
