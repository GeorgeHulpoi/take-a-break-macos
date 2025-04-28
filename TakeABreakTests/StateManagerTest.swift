import Testing
import Foundation
@testable import TakeABreak

@Suite("StateManager test", .timeLimit(.minutes(1)))
struct ManagerTest {
    @Test("should set default props")
    func defaultProps() throws {
        let manager = StateManager()
        let firstRule = Rules.defaultRules[0]
        #expect(manager.currentState == firstRule.state)
        #expect(manager.timeRemaining == firstRule.duration)
    }
    
    @Test("should update when tick()")
    func tick() throws {
        let manager = StateManager()
        manager.rules = Rules([
            Rule(state: .pause, duration: 2),
            Rule(state: .working, duration: 2)
        ])
        
        #expect(manager.currentState == .pause)
        #expect(manager.timeRemaining == 2)
        
        let future = Date(timeIntervalSinceNow: Double(3))
        manager.tick(mockCurrentDate: future)
        
        #expect(manager.currentState == .working)
        #expect(manager.timeRemaining == 1)
    }
    
    @Test("should update when tick() is called in distant future")
    func tickDistantFuture() throws {
        let manager = StateManager()
        manager.rules = Rules([
            Rule(state: .pause, duration: 2),
            Rule(state: .working, duration: 2)
        ])
        
        let future = Date(timeIntervalSinceNow: Double(9))
        manager.tick(mockCurrentDate: future)
        
        #expect(manager.currentState == .pause)
        #expect(manager.timeRemaining == 1)
    }
    
    @Test("timeRemainingText should format after timeRemaining set")
    func formatTimeRemaining() throws {
        let manager = StateManager()
        manager.timeRemaining = 3 * 60 + 5
        #expect(manager.timeRemainingText == "03:05")
    }
}
