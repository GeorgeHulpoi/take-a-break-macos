import SwiftUI
import Combine

@Observable
class OverlayModel {
    var timeRemaining: String
    var description: String?
    private var cancellable: AnyCancellable?
    
    static func create() async -> OverlayModel {
        let timeRemainingText = await StateManager.shared.timeRemainingText
        let description = await StateManager.shared.rules.current.getRandomMessage()
        return OverlayModel(timeRemaining: timeRemainingText, description: description)
    }
    
    init(timeRemaining: String, description: String? = nil) {
        self.timeRemaining = timeRemaining
        self.description = description
        
        cancellable = StateManager.shared.timeRemainingText$
            .sink { value in
                self.timeRemaining = value
            }
    }
    
    deinit {
        _teardown()
    }
    
    func lock() {
        _teardown()
    }
    
    private func _teardown() {
        cancellable?.cancel()
    }
}
