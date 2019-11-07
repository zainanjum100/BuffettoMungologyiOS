//
//  AppDelegate.swift
//  AudioBook
//
//  Created by Anthonio Ez on 02/05/2019.
//  Copyright © 2019 Alisiri. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMobileAds
import FacebookCore
import GoogleSignIn
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate
{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
          if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
            print("The user has not signed in before or they have since signed out.")
          } else {
            print("\(error.localizedDescription)")
          }
          return
        }
        
        else {
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            print(fullName)
        }
        
    }
    
    var window: UIWindow?
    var navController: UINavigationController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        
        GIDSignIn.sharedInstance().clientID = "947349171313-iu36ef51d1ikupn06pda0mnqsreossk7"
        GIDSignIn.sharedInstance().delegate = self
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        
        App.unlogPlay();
        
        App.tape.load()

        navController = UINavigationController();
        navController.isNavigationBarHidden = true
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navController
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        if(App.episodePlaying != nil && App.podcastPlaying != nil)
        {
            App.seekable = true;
            
            if(App.tape.setup())
            {
                if(App.episodePosition > 0)
                {
                    App.tape.seek(App.episodePosition)
                }

                App.tape.pause()
            }
        }
        
        navController.pushViewController(
            SplashViewController.instance(), animated: true)
        
        
        application.beginReceivingRemoteControlEvents()
        
        return true
    }
    
   
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: - Funcs
    public static func setControllers(_ controllers: [UIViewController], animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.setViewControllers(controllers, animated: animated);
    }
    
    public static func pushController(_ controller: UIViewController, animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.pushViewController(controller, animated: animated);
    }
    
    public static func popController(_ animated: Bool)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navController.popViewController(animated: animated);
    }
    
    
    //Then in your UIResponder (or your AppDelegate if you will)
    override func remoteControlReceived(with event: UIEvent?)
    {
        if let event = event
        {
            App.tape.remoteControlReceived(with: event);
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
           return
               ApplicationDelegate.shared.application(app, open: url, options: options)
             
        return GIDSignIn.sharedInstance().handle(url)
       }
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}

