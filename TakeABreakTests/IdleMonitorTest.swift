import Testing
import Foundation
@testable import TakeABreak

@Suite("IdleMonitor Tests", .timeLimit(.minutes(1)))
struct IdleMonitorTests {
    @Test("By default isIdle is false")
    func byDefaultIsIdleIsFalse() throws {
        let (idleMonitor, _, _) = makeIdleMonitor()
        idleMonitor.start()
        
        #expect(idleMonitor.isIdle == false)
        idleMonitor.destroy()
    }
    
    @Test("should set isIdle true")
    func shouldSetIsIdleTrue() throws {
        let (idleMonitor, idleTimer, _) = makeIdleMonitor()
        
        idleMonitor.start()
        
        idleTimer.callHandler()
        #expect(idleMonitor.isIdle == true)
        idleMonitor.destroy()
    }
    
    @Test("event should reset isIdle")
    func eventShouldResetIsIdle() throws {
        let (idleMonitor, idleTimer, eventMonitor) = makeIdleMonitor()
        
        idleMonitor.start()
        
        // Simulate ScheduledTimer
        idleTimer.callHandler()
        
        #expect(idleMonitor.isIdle == true)
        
        // Simulate event
        eventMonitor.emitEvent()
        
        #expect(idleMonitor.isIdle == false)
        idleMonitor.destroy()
        
    }
}


func makeIdleMonitor() -> (IdleMonitor, MockedIdleTimer, MockedEventMonitor) {
    let eventMonitor = MockedEventMonitor()
    let idleTimer = MockedIdleTimer(timeout: 10)
    let idleMonitor = IdleMonitor(eventMonitor: eventMonitor, idleTimer: idleTimer)
    return (idleMonitor, idleTimer, eventMonitor)
}
