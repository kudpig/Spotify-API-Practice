//
//  AccessTokenModel.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import Foundation

struct SpotifyAccessTokenModel: Codable {
    
    let refreshToken: String
    let scope: String
    let tokenType: String
    let token: String
    let expiresIn: Int
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case scope
        case tokenType = "token_type"
        case token = "access_token"
        case expiresIn = "expires_in"
    }
}
