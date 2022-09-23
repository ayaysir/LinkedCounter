//
//  AppDelegate.swift
//  LinkedCounter
//
//  Created by yoonbumtae on 2022/09/23.
//

import UIKit
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if !SessionHandler.shared.isSupported() {
            print("WCSession not supported (f.e. on iPad).")
        }
        
        checkAppFirstrunOrUpdateStatus {
            localStorage.set(0.0, forKey: .cfgTotalCount)
            localStorage.set(30.0, forKey: .cfgPlusCount)
        } updated: {
            
        } nothingChanged: {
            
        }

        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

func checkAppFirstrunOrUpdateStatus(firstrun: () -> (), updated: () -> (), nothingChanged: () -> ()) {
    let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
    // print(#function, currentVersion ?? "", versionOfLastRun ?? "")

    if versionOfLastRun == nil {
        // First start after installing the app
        firstrun()

    } else if versionOfLastRun != currentVersion {
        // App was updated since last run
        updated()

    } else {
        // nothing changed
        nothingChanged()
    }

    UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
    UserDefaults.standard.synchronize()
}


