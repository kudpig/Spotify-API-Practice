//
//  LoginViewController.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet private weak var loginButton: UIButton! {
        didSet {
            loginButton.addTarget(self, action: #selector(tapLoginButton), for: .touchUpInside)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func openURL(url: URL) {
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems,
              let code = queryItems.first(where: {$0.name == "code"})?.value,
              let getState = queryItems.first(where: {$0.name == "state"})?.value,
              getState == API.shared.stateStr
        else {
            return
        }
        
        API.shared.postAuthorizationCode(code: code) { accessToken, error in
            if let error = error {
                print("トークンLoginVC受け取り時\(error.localizedDescription)")
                return
            }
            guard let _accessToken = accessToken else {
                return
            }
            UserDefaults.standard.spotifyAccessToken = _accessToken.token
            Router.shared.showReStart()
        }
    }

}

private extension LoginViewController {
    @objc func tapLoginButton() {
        UIApplication.shared.open(API.shared.oAuthURL, options: [:], completionHandler: nil)
    }
}
