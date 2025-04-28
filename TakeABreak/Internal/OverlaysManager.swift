import SwiftUI
import Combine
import Foundation

final class OverlaysManager {
    static let shared = OverlaysManager()
    
    var overlayWindows = Set<OverlayWindow>()
    private var cancellable: Cancellable?
    
    private init() {}
    
    func start() {
        cancellable = StateManager.shared.$currentState
            .receive(on: RunLoop.main)
            .sink { currentState in
                if currentState == .pause {
                    self.openOverlay()
                } else if currentState == .working {
                    self.closeOverlay()
                }
            }
    }
    
    func destroy() {
        cancellable?.cancel()
    }
    
    private func openOverlay() {
        for screen in NSScreen.screens {
            let overlayWindow = OverlayWindow(screen)
            overlayWindows.insert(overlayWindow)
        }

        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        }
    }

    private func closeOverlay() {
        let windowsToClose = Array(overlayWindows)
        overlayWindows.removeAll()
        
        for overlayWindow in windowsToClose {
            overlayWindow.hideAndClose()
        }
        

        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        }
    }
}
