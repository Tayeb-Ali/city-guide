//
//  AppDelegate.swift
//  trid
//
//  Created by Black on 9/26/16.
//  Copyright © 2016 Black. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseRemoteConfig
import FirebaseAnalytics
import PureLayout
import GoogleMaps
import FBSDKCoreKit
import IQKeyboardManagerSwift
import AppAuth
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    static var deviceToken : String?

    public var window: UIWindow?
    var navigation : UINavigationController!
    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // Google maps key
    let googleMapsApiKey = "AIzaSyB2MnNe7_0TeyjG7Svf0rsdeJi_3v3gBEs"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Check installed or upgrade
        checkAppUpgrade()
        
        // Google Mobile Ads - Admob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        // keyboard manager
        IQKeyboardManager.shared.enable = true
        
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        //AnalyticsConfiguration.shared().setAnalyticsCollectionEnabled(true)
        
        // Use Firebase library to configure APIs
        
        AppState.remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: false)
        AppState.remoteConfig!.configSettings = remoteConfigSettings
        AppState.remoteConfig!.fetch(withExpirationDuration: 3600, completionHandler: {status, error in
            if status == .success {
                debugPrint("Config fetched!")
                AppState.remoteConfig!.activateFetched()
            } else {
                debugPrint("Config not fetched")
                debugPrint("Error \(error!.localizedDescription)")
            }
        })
        
        // Google sign-in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        // Facebook config
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // window
        self.window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor(netHex: AppSetting.Color.blue)
        // navigation
        let splash = SplashViewController(nibName: "SplashViewController", bundle: nil)
        navigation = UINavigationController(rootViewController: splash)
        navigation.isNavigationBarHidden = true
        self.window?.rootViewController = navigation
        self.window?.makeKeyAndVisible()
        
        // Google sign-in
        GIDSignIn.sharedInstance()?.presentingViewController = navigation
        
        // status color
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Google map
        GMSServices.provideAPIKey(googleMapsApiKey)
        
        // Dropdown listening keyboard
        DropDown.startListeningToKeyboard()
        
        // Start checking database connection
        TridService.shared.listenConnectionCheck = {online in
            TridService.shared.listenConnectionCheck = nil
        }
        
        // Register Push notification
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        
        return true
    }
    
    func checkAppUpgrade() {
        let currentVersion = Bundle.main.object(forInfoDictionaryKey:"CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        debugPrint(currentVersion ?? "", versionOfLastRun ?? "")
        if versionOfLastRun == nil {
            // First start after installing the app
        } else if versionOfLastRun != currentVersion {
            MeasurementHelper.updatedVersion(currentVersion ?? "")
            // App was updated since last run
            if versionOfLastRun == "1.0.1" && currentVersion == "1.2.0" {
                PurchaseManager.savePurchasedAllItem()
            }
        } else {
            // nothing changed
        }
        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")
        UserDefaults.standard.synchronize()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Messaging.messaging().shouldEstablishDirectChannel = false // disconnect()
        debugPrint("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        AppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if #available(iOS 9.0, *) {
            if GIDSignIn.sharedInstance().handle(url) {
                return true
            }
        }
        if ApplicationDelegate.shared.application(app, open: url, options: options) {
            return true
        }
        // handle to comeback app when authorization finish
        if currentAuthorizationFlow != nil && (currentAuthorizationFlow?.resumeExternalUserAgentFlow(with: url))! {
            currentAuthorizationFlow = nil
            return true
        }
        // handling here if has any other URL
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        debugPrint("open url = ", url)
        if GIDSignIn.sharedInstance().handle(url) {
            return true
        }
        else if ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        return false
    }
    
    // MARK: - Google delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            debugPrint(error.localizedDescription)
            NotificationCenter.default.post(name: NotificationKey.signInError, object: error)
            return
        }
        // ...
        let authentication = user.authentication
        let credential = GoogleAuthProvider.credential(withIDToken: (authentication?.idToken)!,
                                                          accessToken: (authentication?.accessToken)!)
        // login
        firebaseLoginWith(credential: credential, info: SignInInfo.makeGoogle(idToken: (authentication?.idToken)!, accessToken: (authentication?.accessToken)!))
    }
    
    func firebaseLoginWith(credential: AuthCredential, info: SignInInfo){
        // sign in
        AppLoading.showLoading()
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                debugPrint(error?.localizedDescription ?? "")
                NotificationCenter.default.post(name: NotificationKey.signInError, object: error)
                return
            }
            debugPrint("Firebase signed in -> ", user?.email ?? "")
            // Check user exist
            let fuser = FUser.userWith(firUser: user!, loginProvider: info.provider)
            fuser.fetchInBackground(finish: {er2 in
                if er2 != nil {
                    // Not found -> save
                    fuser.saveInBackground({er3 in
                        AppLoading.hideLoading()
                        if er3 == nil {
                            Utils.signInWith(user: fuser, signinInfo: info)
                        }
                        else{
                            // Not ok -> send notify
                            NotificationCenter.default.post(name: NotificationKey.signInError, object: nil)
                        }
                    })
                }
                else {
                    AppLoading.hideLoading()
                    Utils.signInWith(user: fuser, signinInfo: info)
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
    // MARK: Push notification
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppDelegate.deviceToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = deviceToken
        debugPrint("Device token: \(AppDelegate.deviceToken ?? "nil")")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        // Print full message.
        debugPrint(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Print full message.
        debugPrint(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
    }
    
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
}

extension AppDelegate : MessagingDelegate {
    @available(iOS 10.0, *)
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        debugPrint(remoteMessage.appData)
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
}

