struct Rule: Equatable, Sendable {
    let state: EAppState
    let duration: UInt16
    let message: Optional<[String]>
    
    init(state: EAppState, duration: UInt16) {
        self.init(state: state, duration: duration, message: nil)
    }
    
    init(state: EAppState, duration: UInt16, message: Optional<[String]>) {
        self.state = state
        self.duration = duration
        self.message = message
    }
    
    func getRandomMessage() -> String? {
        return message?.randomElement()
    }
}
