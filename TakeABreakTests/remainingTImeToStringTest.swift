import Testing
@testable import TakeABreak

@Suite("remainingTimeToString tests", .timeLimit(.minutes(1)))
struct RemainingTimeToStringTest {
    @Test("5 should be `00:05`")
    func fiveShouldBe0005() async throws {
        let text = remainingTimeToString(5)
        #expect(text == "00:05")
    }
    
    @Test("185 should be `03:05`")
    func oneHundredEightyFiveShouldBe0305() async throws {
        let text = remainingTimeToString(185)
        #expect(text == "03:05")
    }
}
