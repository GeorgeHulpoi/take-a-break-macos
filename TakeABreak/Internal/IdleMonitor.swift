import SwiftUI
import os

protocol EventMonitor {
    func start(_ handler: @escaping () -> Void)
    func stop()
}

final class DefaultEventMonitor: EventMonitor {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: DefaultEventMonitor.self)
    )
    
    private var globalEventMonitor: Any?

    func start(_ handler: @escaping () -> Void) {
            Self.logger.info("[DefaultEventMonitor]: Starting global event monitor.")
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { event in
            Self.logger.debug("[DefaultEventMonitor]: Detected user event: \(String(describing: event.type), privacy: .public)")
            handler()
        }
    }
    
    func stop() {
        if let globalEventMonitor = globalEventMonitor {
            Self.logger.info("[DefaultEventMonitor]: Stopping global event monitor.")
            NSEvent.removeMonitor(globalEventMonitor)
            self.globalEventMonitor = nil
        } else {
            Self.logger.debug("[DefaultEventMonitor]: DefaultEventMonitor: Stop called, but no monitor was active.")
        }
    }
}

final class MockedEventMonitor: EventMonitor {
    private var handler: (() -> Void)?
    
    func start(_ handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    func stop() {
        self.handler = nil
    }
    
    func emitEvent() {
        handler?()
    }
}

protocol IdleTimer {
    init(timeout: TimeInterval)
    func start(handler: @escaping () -> Void) -> Void
    func reset() -> Void
    func stop() -> Void
}

final class DefaultIdleTimer: IdleTimer {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: DefaultIdleTimer.self)
    )
    
    private var timer: Timer?
    private let timeout: TimeInterval
    private var handler: (() -> Void)?
    
    init(timeout: TimeInterval) {
        self.timeout = timeout
    }
    
    func start(handler: @escaping () -> Void) {
        Self.logger.info("[DefaultIdleTimer]: Starting idle timer with timeout: \(self.timeout, format: .fixed(precision: 2))s")
        self.handler = handler
        createScheduledTimer()
    }
    
    func reset() {
        Self.logger.debug("[DefaultIdleTimer]: Resetting idle timer.")
        timer?.invalidate()
        createScheduledTimer()
    }
    
    func stop() {
        Self.logger.info("[DefaultIdleTimer]: DefaultIdleTimer: Stopping idle timer.")
        timer?.invalidate()
    }
    
    private func createScheduledTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { [weak self] _ in
            Self.logger.debug("[DefaultIdleTimer]: DefaultIdleTimer: Timeout reached — invoking handler.")
            self?.handler?()
        }
    }
}

final class MockedIdleTimer: IdleTimer {
    var handler: (() -> Void)?
    
    init(timeout: TimeInterval) {}
    
    func start(handler: @escaping () -> Void) {
        self.handler = handler
    }
    
    func reset() {}
    
    func stop() {}
    
    func callHandler() {
        handler?()
    }
}

final class IdleMonitor: ObservableObject {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: DefaultIdleTimer.self)
    )
    private static var sharedInstance: IdleMonitor?
    static var shared: IdleMonitor {
        get {
            if let instance = IdleMonitor.sharedInstance {
                Self.logger.debug("[IdleMonitor]: Returning existing shared instance.")
                return instance
            } else {
                Self.logger.debug("[IdleMonitor]: Creating new shared instance.")
                let instance = IdleMonitor()
                IdleMonitor.sharedInstance = instance
                return instance
            }
        }
    }
    static let timeout: TimeInterval = 10 // 10 secs
    
    @Published var isIdle = false
    
    private var idleTimer: IdleTimer! = nil
    private var eventMonitor: EventMonitor
    
    init(eventMonitor: EventMonitor = DefaultEventMonitor(), idleTimer: IdleTimer = DefaultIdleTimer(timeout: IdleMonitor.timeout)) {
        Self.logger.debug("[IdleMonitor]: Initializing with timeout: \(IdleMonitor.timeout, format: .fixed(precision: 2))s.")
        self.eventMonitor = eventMonitor
        self.idleTimer = idleTimer
    }
    
    func start() {
        Self.logger.info("[IdleMonitor]: Starting idle monitoring.")
        eventMonitor.start { [weak self] in
            guard let self = self else { return }
            
            if self.isIdle {
                Self.logger.info("[IdleMonitor]: User activity detected, switching from idle to active.")
                self.isIdle = false
            }
            
            self.idleTimer.reset()
        }
        
        idleTimer.start { [weak self] in
            Self.logger.info("[IdleMonitor]: User became idle.")
            self?.isIdle = true
        }
    }
    
    func destroy() {
        Self.logger.info("[IdleMonitor]: Destroying monitor and stopping timers.")
        eventMonitor.stop()
        idleTimer.stop()
    }
}
