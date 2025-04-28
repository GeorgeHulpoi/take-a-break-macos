import SwiftUI

struct OverlayView: View {
    @SwiftUI.State var model: OverlayModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                Text(model.timeRemaining)
                    .font(.system(size: 72))
                    .bold()
                    .lineLimit(1)
                    .fixedSize()
                    .padding(.vertical, -16)
                if let description = model.description {
                    Text(description)
                        .font(.system(size: 48))
                        .lineLimit(1)
                        .fixedSize()
                }
                Spacer().frame(height: 32)
                Button("Skip") {
                    Task {
                        await StateManager.shared.nextState()
                    }
                }
                .buttonStyle(OutlineButtonStyle())
            }
        }
    }
}

#Preview {
    let model = OverlayModel(timeRemaining: "00:20", description: "Description")
    OverlayView(model: model)
}
