import SwiftUI
import Combine

final class OverlayState: ObservableObject {
    @Published var isLocked: Bool = false {
        didSet {
            if (isLocked) {
                destroy()
            } else {
                listenForTimeRemainingText()
            }
        }
    }
    @Published var title: String
    var description: String?
    
    private var cancellable: AnyCancellable?
    
    init() {
        title = StateManager.shared.timeRemainingText
        description = StateManager.shared.rules.current.getRandomMessage()
        
        listenForTimeRemainingText()
    }
    
    deinit {
        destroy()
    }
    
    private func listenForTimeRemainingText() {
        if cancellable != nil {
            return
        }
        
        cancellable = StateManager.shared.$timeRemainingText
            .receive(on: RunLoop.main)
            .sink { [weak self] timeRemainingText in
                self?.title = timeRemainingText
            }
    }
    
    private func destroy() {
        guard let cancellable = cancellable else {
            return
        }
        
        cancellable.cancel()
        self.cancellable = nil
    }
}
