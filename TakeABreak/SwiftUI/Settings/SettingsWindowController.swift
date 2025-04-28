import Cocoa
import SwiftUI

class SettingsWindowController: NSWindowController, NSWindowDelegate {

    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Take a Break"
        window.isReleasedWhenClosed = true
        
        self.init(window: window)
        
        window.delegate = self

        self.contentViewController = NSHostingController(rootView: SettingsView())
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(windowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: window
        )
    }

    // Notification method
    @objc func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        print("set to accessory")
    }
    
    deinit {
       // Always remove observers to avoid memory leaks
       NotificationCenter.default.removeObserver(self)
   }

}
