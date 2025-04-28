import SwiftUI

struct ContentView: View {
    private static let sharedDefaults = UserDefaults(suiteName: "georgehulpoi.TakeABreak")
    
    @AppStorage("LAUNCH_ON_BOOT", store: sharedDefaults) private var launchOnBoot = false
    @AppStorage("REDUCE_EYE_STRAIN", store: sharedDefaults) private var reduceEyeStrain = true
    @AppStorage("CHECK_FOR_UPDATES", store: sharedDefaults) private var checkForUpdates = false
    
    var body: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    Option("Launch on boot", isOn: $launchOnBoot)
                    Divider()
                    Option("Reduce eye strain", isOn: $reduceEyeStrain)
                    Divider()
                    Option("Check for updates", isOn: $checkForUpdates)
                }.padding(4)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
