//
//  AppDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit
import Fabric
import TwitterKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var deviceToken: String?
    var notificationsDelegate = NotificationsDelegate()
    var bgTask: UIBackgroundTaskIdentifier?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let twitter = TWTRTwitter()
        let (consumerKey, consumerSecret, _) = Config.shared.twitter()
        twitter.start(withConsumerKey: consumerKey, consumerSecret: consumerSecret)
        
//        RestKitObjC.setupLog()
        Fabric.with([Crashlytics.self])
        registerForNotification()
        
        // Setup Amazon S3
        AmazonTool.shared
        
        /// Setup PayPal SDK
        let (production, sandbox) = Config.shared.payment()
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction : production,
            PayPalEnvironmentSandbox : sandbox])
    
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        UINavigationBar.setCustomAppereance()
        /*UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "nav-background"), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().shadowImage = UIImage(named: "nav-border")
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]*/
        


        UserDefaults.standard.removeObject(forKey: "isGlobalStreamsInMain")
        
        //Clear keychain on first run in case of reinstallation
        if !UserDefaults.standard.bool(forKey: "RegularRun") {
            UserDefaults.standard.set(true, forKey: "RegularRun")
            UserDefaults.standard.synchronize()
            
            if let session = A0SimpleKeychain().string(forKey: "PHPSESSID") {
                A0SimpleKeychain().deleteEntry(forKey: "PHPSESSID")
            }
            if let id = A0SimpleKeychain().string(forKey: "id") {
                A0SimpleKeychain().deleteEntry(forKey: "id")
            }
            if let token = A0SimpleKeychain().string(forKey: "token") {
                A0SimpleKeychain().deleteEntry(forKey: "token")
            }
            if let secret = A0SimpleKeychain().string(forKey: "secret") {
                A0SimpleKeychain().deleteEntry(forKey: "secret")
            }
            if let type = A0SimpleKeychain().string(forKey: "type") {
                A0SimpleKeychain().deleteEntry(forKey: "type")
            }
        }
        
        Soundcloud.clientIdentifier = "64a52bb31abd2ec73f8adda86358cfbf"
        Soundcloud.clientSecret = "571dbd5ca1dda6de40ddfe0c56b7118c"
        Soundcloud.redirectURI = ""
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
                    
            // Post notifications to current controllers
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Close/Leave"), object: nil))
            
            // Dismiss all view controllers behind MainViewController
            let root = UIApplication.shared.delegate!.window!?.rootViewController as! UINavigationController
            
            if root.topViewController!.presentedViewController != nil {
                root.topViewController!.presentedViewController!.dismiss(animated: false, completion: nil)
            }
            
            let controllers = root.viewControllers.filter({ ($0 is LoginViewController) || ($0 is RootViewController) })
            root.setViewControllers(controllers, animated: false)
            
        self.bgTask = application.beginBackgroundTask(withName: "Disconnect Live Stream", expirationHandler: { () -> Void in
            application.endBackgroundTask(self.bgTask!)
            self.bgTask = UIBackgroundTaskIdentifier.invalid
        })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if let task = self.bgTask {
            if (task != UIBackgroundTaskIdentifier.invalid)
            {
                UIApplication.shared.endBackgroundTask(task)
                self.bgTask = UIBackgroundTaskIdentifier.invalid;
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Notifications
    
    func registerForNotification() {
        let application = UIApplication.shared
        
        if #available(iOS 8.0, *) {
                let types:UIUserNotificationType = ([.alert, .badge, .sound])
                let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: types, categories: nil)
                application.registerUserNotificationSettings(settings)
                application.registerForRemoteNotifications()
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.noData)
        
        if !UserContainer.shared.isLogged() {
            return
        }
        
        let uid = userInfo["uni-rcpt"] as! UInt
        if uid != UserContainer.shared.logged().id {
            return
        }
        
        let type = userInfo["uni-type"] as! UInt
        
        let name =
        (((userInfo["aps"] as! NSDictionary)["alert"] as! NSDictionary)["loc-args"] as! NSArray)[0] as! String
        
        if type == 1 && name == UserContainer.shared.logged().name {
            return
        }
        
        notificationsDelegate.streamId = userInfo["uni-id"] as? UInt
        UIAlertView.notificationAlert(notificationsDelegate, userInfo: userInfo).show()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        /* Each byte in the data will be translated to its hex value like 0x01 or
        0xAB excluding the 0x part, so for 1 byte, we will need 2 characters to
        represent that byte, hence the * 2 */
        let tokenAsString = NSMutableString()
        
        /* Create a buffer of UInt8 values and then get the raw bytes
        of the device token into this buffer */
        var byteBuffer = [UInt8](repeating: 0x00, count: deviceToken.count)
        (deviceToken as NSData).getBytes(&byteBuffer)
        
        /* Now convert the bytes into their hex equivalent */
        for byte in byteBuffer {
            tokenAsString.appendFormat("%02hhX", byte)
        }
        
        self.deviceToken = tokenAsString as String
    }
    
    private func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError){
        let err: NSError = error
        NSLog("%@",err.localizedDescription)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return TWTRTwitter.sharedInstance().application(app, open: url, options: options)
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Streamini")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

