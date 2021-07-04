//
//  SpotifyUserProfile.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/01.
//

import Foundation

struct UserProfile: Codable {
    //let country: String
    let display_name: String
    //let explicit_content: [String: Int]
    //let external_urls: [String: String]
    //let id: String
    //let product: String
    let images: [UserImage]
}

struct UserImage: Codable {
    let url: String
    
}
