import SwiftUI

@main
struct SettingsHelperApp: App {
    var notificationManager = NotificationManager()
    
    init() {
        print("🏷️ Bundle path: \(Bundle.main.bundlePath)")
    }
    
    var body: some Scene {
        Window("Take a Break Settings", id: "takeABreakSettings") {
            ContentView()
                .frame(width: 300)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 300, height: 0)
    }
}
