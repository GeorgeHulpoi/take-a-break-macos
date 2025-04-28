import Combine
import ServiceManagement
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem = StatusItem()
    private var isIdleCancellable: Cancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        preventMultipleInstances()
        registerAppAsLoginItem()
        setupNotificationCenterListeners()
        setupListeners()
        StateManager.shared.startTimer()
    }

    func applicationWillTerminate(_ notification: Notification) {
        cleanupListeners()
        StateManager.shared.destroy()
        cleanupNotificationCenterListeners()
    }

    private func setupListeners() {
        IdleMonitor.shared.start()
        OverlaysManager.shared.start()
        
        isIdleCancellable = IdleMonitor.shared.$isIdle
            .receive(on: RunLoop.main)
            .sink { isIdle in
                guard StateManager.shared.currentState == .working else { return }

                StateManager.shared.reset()
                if isIdle {
                    StateManager.shared.destroy()
                } else {
                    StateManager.shared.startTimer()
                }
            }
    }
    
    private func cleanupListeners() {
        IdleMonitor.shared.destroy()
        OverlaysManager.shared.destroy()
        isIdleCancellable?.cancel()
    }

    private func setupNotificationCenterListeners() {
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemWillSleep),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(systemDidWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )
    }
    
    private func cleanupNotificationCenterListeners() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func preventMultipleInstances() {
        let runningApps = NSRunningApplication.runningApplications(withBundleIdentifier: Bundle.main.bundleIdentifier!)

        if runningApps.count > 1 {
            NSApplication.shared.terminate(nil)
        }
    }

    private func registerAppAsLoginItem() {
        if SMAppService.mainApp.status != .enabled {
            try? SMAppService.mainApp.register()
        }
    }

    @objc func systemWillSleep(notification: Notification) {
        StateManager.shared.destroy()
        cleanupListeners()
    }

    @objc func systemDidWake(notification: Notification) {
        StateManager.shared.reset()
        StateManager.shared.startTimer()
        setupListeners()
    }
}
