import Foundation
import SwiftUI

struct SpacingSettingsBundle: View {
    @AppStorage("tabmode") var mode: Int = 0
    @AppStorage("tabspacing") var spacing: Int = 4

    var body: some View {
        List {
            Section(header: Text("Mode")) {
                Picker("", selection: $mode) {
                    Text("tab").tag(0)
                    Text("spaces").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            if mode == 1 {
                Stepper("Spaces: \(spacing)", value: $spacing, in: 2...8)
            }
        }
        .navigationTitle("Spacing")
        .navigationBarTitleDisplayMode(.inline)
    }
}
