import SwiftUI

struct OverlayContentView: View {
    @Binding var title: String
    @State private var showConfirmation = false
    var description: String?
    var onSkip: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text(title)
                    .font(.system(size: 72))
                    .bold()
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.vertical, -16)
                if let description = description {
                    Text(description)
                        .font(.system(size: 48))
                        .lineLimit(1)
                        .fixedSize()
                }
                Spacer().frame(height: 32)
                Button("Skip") {
                    showConfirmation = true
                }
                .buttonStyle(OutlineButtonStyle())
                .confirmationDialog("Is your work more important than your health?", isPresented: $showConfirmation) {
                    Button("Not sure", role: .cancel) {
                        showConfirmation = false
                    }
                    Button("Yes", role: .none) {
                        onSkip?()
                    }
                }
            }
        }
    }
}

#Preview {
    OverlayContentView(title: Binding.constant("Title"), description: "Description")
}
