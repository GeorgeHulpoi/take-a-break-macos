import SwiftUI

struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(.secondary)
            .background(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                ).stroke(Color.secondary)
            )
            .contentShape(Rectangle())
            .font(.system(size: 13))
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
