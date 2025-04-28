import SwiftUI

struct SettingsView: View {
    @AppStorage("LAUNCH_ON_BOOT") private var launchOnBoot = false
    @AppStorage("REDUCE_EYE_STRAIN") private var reduceEyeStrain = true
    @AppStorage("CHECK_FOR_UPDATES") private var checkForUpdates = false
    
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
        .frame(width: 300)
    }
}

#Preview {
    SettingsView()
}
