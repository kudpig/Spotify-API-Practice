//
//  Extension-UserDefaults.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import Foundation

extension UserDefaults {
    private var spotifyAccessTokenKey: String { "qiitaAccessTokenKey" }
    var spotifyAccessToken: String {
        get {
            self.string(forKey: spotifyAccessTokenKey) ?? ""
        }
        set {
            self.setValue(newValue, forKey: spotifyAccessTokenKey)
        }
    }
}
