import SwiftUI

struct OverlayView: View {
    @ObservedObject var overlayState: OverlayState
    
    var body: some View {
        OverlayContentView(title: $overlayState.title, description: overlayState.description) {
            StateManager.shared.nextState()
        }
    }
}
