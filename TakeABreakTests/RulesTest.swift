import Testing
@testable import TakeABreak

@Suite("Rules tests", .timeLimit(.minutes(1)))
struct RulesTest {
    @Test("should init with default items")
    func defaultItems() async throws {
        var rules = Rules()
        #expect(rules.items.elementsEqual(Rules.defaultRules) { $0 == $1 })
        rules = Rules([])
        #expect(rules.items.elementsEqual(Rules.defaultRules) { $0 == $1 })
    }
    
    @Test("should init with given items")
    func customRules() async throws {
        let items: [Rule] = [
            Rule(state: .working, duration: 20 * 60),
            Rule(state: .pause, duration: 20),
        ]
        let rules = Rules(items)
        #expect(rules.items.elementsEqual(items) { $0 == $1 })
    }
    
    @Test(".current should return the first item from default rules")
    func currentReturnsFirst() async throws {
        let rules = Rules()
        #expect(rules.current == Rules.defaultRules[0])
    }
    
    @Test(".items should act like a circular graph when using next()")
    func nextShouldRepeat() async throws {
        let items: [Rule] = [
            Rule(state: .working, duration: 20 * 60),
            Rule(state: .pause, duration: 20),
        ]
        var rules = Rules(items)
        var current = rules.next()
        #expect(current == items[1])
        current = rules.next()
        #expect(current == items[0])
    }
}
