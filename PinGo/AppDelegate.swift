//
//  AppDelegate.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/2/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //apply google API key

        GMSServices.provideAPIKey("AIzaSyAGchBkxmMWBnbPvLRY3jUbnZeyjZWxknI")
//        GMSPlacesClient.provideAPIKey("AIzaSyAGchBkxmMWBnbPvLRY3jUbnZeyjZWxknI")
        
       
        //get user info
        if UserProfile.currentUser != nil{
            print("There is a current user")
            let isWorker = (UserProfile.currentUser?.isWorker)!
            if isWorker {
                let storyboard = UIStoryboard( name: "Worker", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UITabBarController
                
                window?.rootViewController = vc
                
                
            } else {
                let storyboard = UIStoryboard( name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! UITabBarController
                window?.rootViewController = vc
                
            }
            
            
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName(UserProfile.userDidLogOutNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) in
            
            let storyboard = UIStoryboard( name: "LoginStoryboard", bundle: nil)
            
            let vc = storyboard.instantiateInitialViewController()
            
            self.window?.rootViewController = vc
        }
        
        
        //customizeAppearance()
        
        return true
    }
    
    func customizeAppearance() {
        //customize navigation bar
        UINavigationBar.appearance().barTintColor = UIColor(red: 37.0/255.0, green: 55.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor() //color of the back button
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //color of title
        //customize the status bar
        //UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        //customize the tab bar
        UITabBar.appearance().barTintColor = UIColor(red: 37.0/255.0, green: 55.0/255.0, blue: 68.0/255.0, alpha: 1.0)
        UITabBar.appearance().tintColor = UIColor(red: 243.0/255.0, green: 190.0/255.0, blue: 118.0/255.0, alpha: 1.0)
        
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketManager.sharedInstance.closeConnection()
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        SocketManager.sharedInstance.establishConnection()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

