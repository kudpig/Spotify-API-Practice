//
//  AppDelegate.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var window: UIWindow?
    //private var loginViewController: LoginViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //let window = UIWindow(frame: UIScreen.main.bounds)
        //self.window = window
        //
        //let storyboard = UIStoryboard(name: "Login", bundle: nil)
        //let vc = storyboard.instantiateInitialViewController() as! LoginViewController
        //let nav = UINavigationController(rootViewController: vc)
        //
        //self.loginViewController = vc
        //
        //window.rootViewController = nav
        //window.makeKeyAndVisible()
        
        Router.shared.showRoot(window: UIWindow(frame: UIScreen.main.bounds))
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        
        //guard let loginViewController = self.loginViewController else {
        //  return true
        //}
        //
        //print("AppDelegateに戻ってきた")
        //print("リダイレクトパラメータ(URL)：\(url)")
        //loginViewController.openURL(url: url)
        Router.shared.afterRedirect(url: url)
        
        return true
    }
    
}
