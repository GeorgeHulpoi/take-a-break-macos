import SwiftUI
import Combine
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: StatusItem?
    var timer: Timer?
    private var cancellables: [AnyCancellable] = []
    
    var overlayWindows: [OverlayWindow] = []
    var overlayModel: OverlayModel?
    
    override init() {
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        _registerAppAsLoginItem()
        _preventMultipleInstances()
        _setupCurrentStateListener()
        _setupTickTimer()
        
        Task { @MainActor in
            await StateManager.shared.tick()
            await _setupStatusItem()
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }
    
    private func _setupStatusItem() async {
        let timeRemainingText = await StateManager.shared.timeRemainingText
        statusItem = await StatusItem(timeRemainingText)
    }
    
    private func _setupCurrentStateListener() {
        cancellables.append(
            StateManager.shared.currentState$
                .sink { currentState in
                    if currentState == .pause {
                        Task {
                            await self._openOverlay()
                        }
                    } else if currentState == .working {
                        Task {
                            await self._closeOverlay()
                        }
                    }
                }
        )
    }
    
    private func _openOverlay() async {
        overlayModel = await OverlayModel.create()
    
        
        for screen in NSScreen.screens {
            let window = await OverlayWindow(frame: screen.frame, model: overlayModel!)
            overlayWindows.append(window)
        }
        
        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        }
    }
    
    private func _closeOverlay() async {
        overlayModel?.lock()
        
        let windowsToClose = self.overlayWindows
        self.overlayWindows.removeAll()
        
        for win in windowsToClose {
            await win.hideAndClose()
        }
        
        if let sound = NSSound(named: "Sosumi") {
            sound.play()
        }
    }
    
    private func _preventMultipleInstances() {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)

        if runningApps.count > 1 {
            NSApplication.shared.terminate(nil)
        }
    }
    
    private func _setupTickTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            Task {
                await StateManager.shared.tick()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    private func _registerAppAsLoginItem() {
        if SMAppService.mainApp.status != .enabled {
            try? SMAppService.mainApp.register()
        }
    }
}
