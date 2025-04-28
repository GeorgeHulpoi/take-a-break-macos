import SwiftUI

class NotificationManager {
    private let sharedDefaults = UserDefaults(suiteName: "georgehulpoi.TakeABreak")
    
    init() {
        print("init")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userDefaultsChanged),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }
    
    @objc func userDefaultsChanged(_ notification: Notification) {
        if let userDefaults = self.sharedDefaults {
            let launchOnBoot = userDefaults.bool(forKey: "LAUNCH_ON_BOOT")
            let reduceEyeStrain = userDefaults.bool(forKey: "REDUCE_EYE_STRAIN")
            let checkForUpdates = userDefaults.bool(forKey: "CHECK_FOR_UPDATES")
            let userInfo = [
                "launchOnBoot": launchOnBoot,
                "reduceEyeStrain": reduceEyeStrain,
                "checkForUpdates": checkForUpdates,
            ]
            print("SettingsHelper: settings modified")
            DispatchQueue.main.async {
                DistributedNotificationCenter.default().post(
                    name: Notification.Name("georgehulpoi.TakeABreak.settingsChanged"),
                    object: nil,
                    userInfo: userInfo
                )
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
