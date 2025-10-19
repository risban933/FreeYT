//
//  AppDelegate.swift
//  FreeYT
//
//  Created by Rishabh Bansal on 10/19/25.
//

import UIKit
import SafariServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // This check is for Mac Catalyst to see if the extension is enabled.
        #if targetEnvironment(macCatalyst)
        if #available(iOS 15.0, *) {
            // Make sure this identifier matches your extension's Bundle ID
            let extensionIdentifier = "com.freeyt.app.extension"
            SFSafariWebExtensionManager.getStateOfSafariWebExtension(withIdentifier: extensionIdentifier) { state, error in
                if let error = error {
                    print("[FreeYT] Safari Web Extension state error:", error.localizedDescription)
                    return
                }
                guard let state = state else {
                    print("[FreeYT] Safari Web Extension state unavailable.")
                    return
                }
                if state.isEnabled {
                    print("[FreeYT] Web Extension is installed and enabled.")
                } else {
                    print("[FreeYT] Web Extension is installed but NOT enabled. Open Safari > Settings > Extensions to enable it.")
                }
            }
        }
        #endif
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
}
