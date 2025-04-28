import SwiftUI

final class IdleMonitor: ObservableObject {
    static let shared = IdleMonitor()
    
    @Published private(set) var isIdle = false
    private var idleTimer: Timer?
    private let timeout: TimeInterval = 10 // 10 secs
    private var globalEventMonitor: Any?
    
    private init() {}
    
    func start() {
        startMonitoring()
        resetTimer()
    }
    
    func destroy() {
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        if let timer = idleTimer {
            timer.invalidate()
            idleTimer = nil
        }
    }
    
    private func startMonitoring() {
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.resetTimer()
        }
    }
    
    private func resetTimer() {
        if isIdle {
            isIdle = false
        }
        
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            self?.isIdle = true
        }
    }
}
