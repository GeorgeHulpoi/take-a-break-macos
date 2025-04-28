import Combine
import SwiftUI

@MainActor
class StatusItem {
    var statusItem: NSStatusItem
    private var cancellables: [AnyCancellable] = []
    
    init(_ initialTitle: String) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Take a break")
            button.target = self
            button.title = initialTitle
        }
        
        let menu = NSMenu()
        
        let resetItem = NSMenuItem(title: "Reset", action: #selector(reset), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
        
        cancellables.append(
            StateManager.shared.timeRemainingText$
                .receive(on: DispatchQueue.main)
                .sink { timeRemainingText in
                    if let button = self.statusItem.button {
                        button.title = timeRemainingText
                    }
                }
        )
    }
    
    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc func reset() {
        Task {
            await StateManager.shared.reset()
            await StateManager.shared.tick()
        }
    }
}
