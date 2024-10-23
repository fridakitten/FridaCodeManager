import SwiftUI

struct PickerItems: Identifiable {
    let id: Int
    let name: String
}

struct PickerArrays: Identifiable {
    let id: UUID = UUID()
    let title: String
    let items: [PickerItems]
}

struct POPicker: View {
    let function: () -> Void

    var title: String
    var arrays: [PickerArrays]
    @Binding var type: Int

    var body: some View  {
        HStack {
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text(title)
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $type) {
                        ForEach(arrays) { item in
                            if ProcessInfo.processInfo.isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 16, minorVersion: 0, patchVersion: 0)) {
                                Section(header: Text(item.title)) {
                                    ForEach(item.items) { subItem in
                                        Text(subItem.name).tag(subItem.id)
                                    }
                                }
                            } else {
                                Section {
                                    ForEach(item.items) { subItem in
                                        Text("\(subItem.name) (\(item.title))").tag(subItem.id)
                                    }
                                }
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    Spacer()
                }
            }
            .frame(height: 36)
            .background(Color(.systemBackground).opacity(0.7))
            .foregroundColor(.primary)
            .accentColor(.secondary)
            .cornerRadius(10)

            Spacer()

            Button(action: {
                function()
            }, label: {
                Text("Submit")
                    .frame(width: 80, height: 36)
                    .background(Color(.systemBackground).opacity(0.7))
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            })
        }
        .frame(height: 36)
    }
}

