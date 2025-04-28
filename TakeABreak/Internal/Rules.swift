
struct Rules: Sendable {
    static let defaultRules: [Rule] = [
        Rule(state: EAppState.working, duration: 5),
        Rule(state: EAppState.pause, duration: 5, message: ["Look 20m away"]),
    ]
        
//    static let defaultRules: [Rule] = [
//        Rule(state: EAppState.working, duration: 20 * 60),
//        Rule(state: EAppState.pause, duration: 20, message: ["Look 20m away"]),
//        Rule(state: EAppState.working, duration: 20 * 60),
//        Rule(state: EAppState.pause, duration: 20, message: ["Look 20m away"]),
//        Rule(state: EAppState.working, duration: (10 * 60) - 40),
//        Rule(state: EAppState.pause, duration: 10 * 60, message: ["Get up and walk"])
//    ]
    
    var items: [Rule] = []
    private var activeIndex: Int = 0
    var current: Rule {
        let i = activeIndex
        return items[i]
    }
    
    init() {
        items = Rules.defaultRules
    }
    
    init(_ rules: [Rule]) {
        if (rules.isEmpty) {
            items = Rules.defaultRules
        } else {
            items = rules
        }
    }
    
    mutating func next() -> Rule {
        if activeIndex < items.count - 1 {
            activeIndex += 1
        } else {
            activeIndex = 0
        }
        return current
    }
    
    mutating func resetToFirst() -> Rule {
        activeIndex = 0
        return current
    }
}
