//
//  AppDelegate.swift
//  RoamExample
//
//  Created by GeoSpark on 04/08/22.
//

import UIKit
import Roam

@main
class AppDelegate: UIResponder, UIApplicationDelegate,RoamDelegate{
   


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Roam.initialize("410a3cc25f7cf783420fde6b45427f2cf2035525f036e534fa61b827e9b1de0d")
        Roam.delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print(granted)
            print(error.debugDescription)
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
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
    
    func didUpdateLocation(_ locations: [RoamLocation]) {
        self.showNotification(locations)
    }
    
    func showNotification(_ motion:[RoamLocation]){
        let content = UNMutableNotificationContent()
        content.title = "Location \(String(describing: motion[0].userId!))"
        content.subtitle = motion[0].location.description
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01".random(), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }



}

