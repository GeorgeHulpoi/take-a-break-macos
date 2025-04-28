import Foundation
import Combine

actor StateManager {
    static var shared = StateManager()
    
    var rules: Rules = Rules() {
        didSet {
            currentState = rules.current.state
            timeRemaining = rules.current.duration
            nextStateDate = Date(timeIntervalSinceNow: Double(rules.current.duration))
        }
    }
    private(set) var currentState: State {
        didSet {
            if (currentState != oldValue) {
                currentState$.send(currentState)
            }
        }
    }
    private(set) var nextStateDate: Date
    private(set) var timeRemaining: UInt16 = 0 {
        didSet {
            if (timeRemaining != oldValue) {
                timeRemainingText = remainingTimeToString(timeRemaining)
                timeRemainingText$.send(timeRemainingText)
            }
        }
    }
    private(set) var timeRemainingText: String = ""
    
    nonisolated let timeRemainingText$ = PassthroughSubject<String, Never>()
    nonisolated let currentState$ = PassthroughSubject<State, Never>()

    init() {
        currentState = rules.current.state
        timeRemaining = rules.current.duration
        nextStateDate = Date(timeIntervalSinceNow: Double(rules.current.duration))
    }
    
    func tick(mockCurrentDate: Date? = nil) {
        let currentDate = mockCurrentDate ?? Date()
        
        var nextDate = nextStateDate
        var compResult = currentDate.compare(nextDate)
        
        while (compResult == .orderedSame || compResult == .orderedDescending) {
            let currentRule = rules.next()
            nextDate = nextDate.addingTimeInterval(Double(currentRule.duration))
            compResult = currentDate.compare(nextDate)
        }
        
        self.currentState = rules.current.state
        self.timeRemaining = UInt16(nextDate.timeIntervalSince(currentDate).rounded(.up))
    }
    
    func nextState() {
        let nextRule = rules.next()
        currentState = nextRule.state
        nextStateDate = Date(timeIntervalSinceNow: Double(nextRule.duration))
        timeRemaining = UInt16(nextStateDate.timeIntervalSince(Date()).rounded(.up))
    }
    
    func setRules(_ rules: Rules) {
        self.rules = rules
    }
    
    func setTimeRemaining(_ timeRemaining: UInt16) {
        self.timeRemaining = timeRemaining
    }
    
    func reset() {
        let firstRule = rules.resetToFirst()
        currentState = firstRule.state
        nextStateDate = Date(timeIntervalSinceNow: Double(firstRule.duration))
        timeRemaining = UInt16(nextStateDate.timeIntervalSince(Date()).rounded(.up))
    }
}
