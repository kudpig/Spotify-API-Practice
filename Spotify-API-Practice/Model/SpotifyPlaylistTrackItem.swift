//
//  PlaylistTrackItem.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/03.
//

import Foundation

struct PlaylistTrackItem: Codable {
    let href: String
    let items: [Tracks]
}

struct Tracks: Codable {
    let track: TrackItem
}

struct TrackItem: Codable {
    let artists: [Artist]
    let album: TrackAlbum
    let href: String
    let id: String
    let name: String
}
struct Artist: Codable {
    let href: String
    let id: String
    let name: String
}

struct TrackAlbum: Codable {
    let images: [TrackImage]?
}

struct TrackImage: Codable {
    let height: Int
    let width: Int
    let url: String
}
// 64, 300, 640
