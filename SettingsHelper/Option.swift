import SwiftUI

struct Option: View {
    let text: String
    var isOn: Binding<Bool>

    init(_ text: String, isOn: Binding<Bool>) {
        self.text = text
        self.isOn = isOn
    }
    
    var body: some View {
        HStack(spacing: 16) {
        Text(text)
            Spacer()
            Toggle("", isOn: isOn)
            .toggleStyle(.switch)
        }
        .frame(maxWidth: .infinity)
    }
}
