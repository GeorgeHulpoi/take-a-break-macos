import Combine
import Foundation

final class StateManager: ObservableObject {
    static let shared = StateManager()

    var rules = Rules() {
        didSet {
            if (currentState != rules.current.state) {
                currentState = rules.current.state
            }
            
            if (timeRemaining != rules.current.duration) {
                timeRemaining = rules.current.duration
            }
            
            nextStateDate = Date(timeIntervalSinceNow: Double(rules.current.duration))
        }
    }

    private(set) var nextStateDate: Date
    private var timer: Timer?
    
    @Published var currentState: EAppState
    @Published var timeRemaining: UInt16 {
        didSet {
            timeRemainingText = remainingTimeToString(timeRemaining)
        }
    }

    @Published var timeRemainingText: String = ""
    
    init() {
        currentState = rules.current.state
        timeRemaining = rules.current.duration
        nextStateDate = Date(timeIntervalSinceNow: Double(rules.current.duration))
        
        tick()
    }
    
    func startTimer() {
        destroy()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.tick()
        }
    }
    
    func destroy() {
        timer?.invalidate()
    }
    
    func tick(mockCurrentDate: Date? = nil) {
        let currentDate = mockCurrentDate ?? Date()

        var nextDate = nextStateDate
        var compResult = currentDate.compare(nextDate)

        while compResult == .orderedSame || compResult == .orderedDescending {
            let currentRule = rules.next()
            nextDate = nextDate.addingTimeInterval(Double(currentRule.duration))
            compResult = currentDate.compare(nextDate)
        }

        if (currentState != rules.current.state) {
            currentState = rules.current.state
        }

        let newTimeRemaining = UInt16(nextDate.timeIntervalSince(currentDate).rounded(.up))
        if (timeRemaining != newTimeRemaining) {
            timeRemaining = UInt16(nextDate.timeIntervalSince(currentDate).rounded(.up))
        }
    }
    
    func nextState() {
        let nextRule = rules.next()
        
        if (currentState != nextRule.state) {
            currentState = nextRule.state
        }
        
        nextStateDate = Date(timeIntervalSinceNow: Double(nextRule.duration))
        
        let newTimeRemaining = UInt16(nextStateDate.timeIntervalSince(Date()).rounded(.up))
        
        if (timeRemaining != newTimeRemaining) {
            timeRemaining = newTimeRemaining
        }
    }
    
    func reset() {
        let firstRule = rules.resetToFirst()
        
        if (currentState != firstRule.state) {
            currentState = firstRule.state
        }

        nextStateDate = Date(timeIntervalSinceNow: Double(firstRule.duration))
        
        let newTimeRemaining = UInt16(nextStateDate.timeIntervalSince(Date()).rounded(.up))
        
        if (timeRemaining != newTimeRemaining) {
            timeRemaining = newTimeRemaining
        }
    }
}
