import Combine
import SwiftUI

final class StatusItem {
    private var nativeStatusItem: NSStatusItem
    private var cancellables = Set<AnyCancellable>()

    init() {
        nativeStatusItem = NSStatusBar.system.statusItem(withLength: 54)

        if let button = nativeStatusItem.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Take a break")
            button.target = self
            button.title = StateManager.shared.timeRemainingText
        }

        let menu = NSMenu()

        let resetItem = NSMenuItem(title: "Reset", action: #selector(reset), keyEquivalent: "")
        resetItem.target = self
        menu.addItem(resetItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "")
        quitItem.target = self
        menu.addItem(quitItem)

        nativeStatusItem.menu = menu

        StateManager.shared.$timeRemainingText
            .receive(on: RunLoop.main)
            .sink { [weak self] timeRemainingText in
                guard let self = self else { return }
                if let button = self.nativeStatusItem.button {
                    button.title = timeRemainingText
                }
            }
            .store(in: &cancellables)
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
        StateManager.shared.reset()
    }
}
