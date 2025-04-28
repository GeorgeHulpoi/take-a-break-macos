import SwiftUI

@MainActor
class OverlayWindow {
    var window: NSWindow
    
    init(frame: NSRect, model: OverlayModel) {
        window = NSWindow(contentRect: frame, styleMask: .borderless, backing: .buffered, defer: false)
        window.level = .screenSaver
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false
        window.isOpaque = true
        window.backgroundColor = NSColor.black.withAlphaComponent(0)
        window.setFrame(frame, display: true)

        let contentView = OverlayView(model: model).frame(width: frame.width, height: frame.height)
            .ignoresSafeArea()

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = frame
        window.contentView = hostingView

        _showWindowWithFadeIn(window)
    }
    
    func close() {
        window.orderOut(nil)
    }
    
    private func _showWindowWithFadeIn(_ window: NSWindow) {
        window.alphaValue = 0
        window.orderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            window.animator().alphaValue = 1
        }
    }
    
    func hideAndClose() {
        window.alphaValue = 1

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            window.animator().alphaValue = 0
        }, completionHandler: {
            self.close()
        })
    }
}
