//
//  SpotifyCurrentlyPlayingTrack.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/02.
//

import Foundation

struct CurrentUserPlayingList: Codable {
    let href: String
    let items: [PlayingListItem]
}

struct PlayingListItem: Codable {
    let id: String
    let name: String
    let images: [Image]
}

struct Image: Codable {
    let height: Int
    let width: Int
    let url: String
}
