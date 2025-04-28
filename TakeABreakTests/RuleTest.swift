import Testing
@testable import TakeABreak

@Suite("Rule tests", .timeLimit(.minutes(1)))
struct RuleTests {
    @Test(".getRandomMessage() should return an item from messages")
    func getRandomMessageShouldReturnElement() async throws {
        let messages = ["message1", "message2"]
        let rule = Rule(state: .working, duration: 20 * 60, message: messages)
        #expect(messages.contains(rule.getRandomMessage()!))
    }
}
