import SwiftUI

final class OverlayWindow: Hashable {
    var overlayState = OverlayState()
    private var nativeWindow: NSWindow
    private let id = UUID()
    
    init(_ screen: NSScreen) {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .screenSaver
        window.ignoresMouseEvents = false
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.hasShadow = false
        window.isOpaque = true
        window.backgroundColor = NSColor.black.withAlphaComponent(0)
        let contentView = OverlayView(overlayState: overlayState).frame(width: screen.frame.width, height: screen.frame.height)
            .ignoresSafeArea()

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.frame = screen.frame
        window.contentView = hostingView
        
        nativeWindow = window
        
        showWindowWithFadeIn()
    }
    
    func close() {
        nativeWindow.orderOut(nil)
    }
    
    func hideAndClose(onHide: (() -> Void)? = nil) {
        overlayState.isLocked = true
        nativeWindow.alphaValue = 1
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            nativeWindow.animator().alphaValue = 0
        } completionHandler: {
            self.nativeWindow.orderOut(nil)
            
            onHide?()
        }
    }
    
    private func showWindowWithFadeIn() {
        nativeWindow.alphaValue = 0
        nativeWindow.orderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            nativeWindow.animator().alphaValue = 1
        }
    }
    
    static func == (a: OverlayWindow, b: OverlayWindow) -> Bool {
        return a.id == b.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
