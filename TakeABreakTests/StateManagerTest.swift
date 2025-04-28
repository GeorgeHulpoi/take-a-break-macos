import Testing
import Foundation
@testable import TakeABreak

@Suite("StateManager test", .timeLimit(.minutes(1)))
struct ManagerTest {
    @Test("should set default props")
    func defaultProps() async throws {
        let manager = StateManager()
        let firstRule = Rules.defaultRules[0]
        #expect(await manager.currentState == firstRule.state)
        #expect(await manager.timeRemaining == firstRule.duration)
    }
    
    @Test("should update when tick()")
    func tick() async throws {
        let manager = StateManager()
        await manager.setRules(
            Rules([
                Rule(state: .pause, duration: 2),
                Rule(state: .working, duration: 2)
            ])
        )
        
        #expect(await manager.currentState == State.pause)
        #expect(await manager.timeRemaining == 2)
        
        let future = Date(timeIntervalSinceNow: Double(3))
        await manager.tick(mockCurrentDate: future)
        
        #expect(await manager.currentState == State.working)
        #expect(await manager.timeRemaining == 1)
    }
    
    @Test("should update when tick() is called in distant future")
    func tickDistantFuture() async throws {
        let manager = StateManager()
        await manager.setRules(
            Rules([
                Rule(state: .pause, duration: 2),
                Rule(state: .working, duration: 2)
            ])
        )
        
        let future = Date(timeIntervalSinceNow: Double(9))
        await manager.tick(mockCurrentDate: future)
        
        #expect(await manager.currentState == State.pause)
        #expect(await manager.timeRemaining == 1)
    }
    
    @Test("timeRemainingText should format after timeRemaining set")
    func formatTimeRemaining() async throws {
        let manager = StateManager()
        await manager.setTimeRemaining(3 * 60 + 5)
        #expect(await manager.timeRemainingText == "03:05")
    }
}
