//
//  Router.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/06.
//

import UIKit

final class Router {
    static let shared: Router = .init()
    private init() {}
    
    private var window: UIWindow?
    private var loginViewController: LoginViewController?
    
    func showRoot(window: UIWindow?) {
        //パラメータから初期画面を切り替える
        if UserDefaults.standard.spotifyAccessToken.isEmpty {
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! LoginViewController
            let nav = UINavigationController(rootViewController: vc)
            self.loginViewController = vc
            window?.rootViewController = nav
        } else {
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let vc = storyboard.instantiateInitialViewController() as! HomeViewController
            let nav = UINavigationController(rootViewController: vc)
            window?.rootViewController = nav
        }
        window?.makeKeyAndVisible()
        self.window = window
    }
    
    func showReStart() {
        // 最初から画面を構築しなおす
        showRoot(window: window)
    }
    
    
    func afterRedirect(url: URL) {
        guard let loginViewController = self.loginViewController else {
            return
        }
        loginViewController.openURL(url: url)
    }
    
}
