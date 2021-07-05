//
//  APICaller.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import Foundation

import Alamofire

enum APIError: Error {
    case postAuthorizationCode
    case getItems
    case failedToGetData
}

final class API {
    
    static let shared = API()
    private init() {}
    
    struct Contstants {
        static let clientID = "clientID"
        static let clientSecret = "clientSecret"
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    let base = "https://accounts.spotify.com/authorize"
    // scopeとscopeの間は%20
    let scopes = "user-read-private%20user-read-recently-played%20user-read-currently-playing%20user-read-playback-state%20playlist-read-private%20playlist-read-collaborative"
    let redirectURI = "kudpigspotifypractice://callback"
    let stateStr = "34fFs29kd09"

    let getTokenEndPoint = "https://accounts.spotify.com/api/token"
    let grantType = "authorization_code"
    
    let getTokenHeaders: HTTPHeaders = [
        "Authorization": "Basic aaaaabbbbbccccc"
    ]
    //"Authorization": "Basic \(Contstants.clientID):\(Contstants.clientSecret))"
    
    enum  URLParameterName: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case redirectURI = "redirect_uri"
        case scope = "scope"
        case state = "state"
        case code = "code"
        case grantType = "grant_type"
    }
    

    var oAuthURL: URL {
        return URL(string: "\(base)?response_type=code&client_id=\(Contstants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&state=\(stateStr)&show_dialog=TRUE")!
        // show_dialog=TRUE
        // ユーザーがすでにアプリを承認している場合に、再度承認するように強制するかどうかを指定します
        // trueの場合、ユーザーは自動的にはリダイレクトされず、再度アプリを承認しなければなりません(デフォルトはfalse)
    }
    
    func postAuthorizationCode(code: String, completion: ((SpotifyAccessTokenModel?, Error?) -> Void)? = nil) {
        
        guard let url = URL(string: getTokenEndPoint) else {
            completion?(nil, APIError.postAuthorizationCode)
            return
        }
        
        // デフォルトのURLセッションでボディ送る場合
        var compornents = URLComponents()
        compornents.queryItems = [
            URLQueryItem(name: URLParameterName.grantType.rawValue, value: grantType),
            URLQueryItem(name: URLParameterName.code.rawValue, value: code),
            URLQueryItem(name: URLParameterName.redirectURI.rawValue, value: redirectURI)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = compornents.query?.data(using: .utf8)
        
        let basicAuthCode = Contstants.clientID+":"+Contstants.clientSecret
        let data = basicAuthCode.data(using: .utf8)
        guard let base64AuthCode = data?.base64EncodedString() else {
            print("base64エンコードエラー")
            completion?(nil, APIError.postAuthorizationCode)
            return
        }
        
        request.setValue("Basic \(base64AuthCode)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
        
            guard let data = data, error == nil else {
                completion?(nil, APIError.postAuthorizationCode)
                return
            }
        
            do {
                let accessToken = try JSONDecoder().decode(SpotifyAccessTokenModel.self, from: data)
                completion?(accessToken, nil)
            }
            catch let error {
                completion?(nil, error)
            }
        }
        task.resume()
        
        // AFでリクエストした場合のコード
        //let parameters = [
        //    "grant_type": "authorization_code",
        //    "code": code,
        //    "redirect_uri": redirectURI
        //]
        //
        //AF.request(url, method: .post, parameters: parameters, headers: getTokenHeaders).responseJSON { (response) in
        //
        //    print("postのレスポンス:\(response)")
        //    do {
        //        guard let _data = response.data else {
        //            completion?(nil, APIError.postAuthorizationCode)
        //            return
        //        }
        //        let accessToken = try JSONDecoder().decode(SpotifyAccessTokenModel.self, from: _data)
        //        completion?(accessToken, nil)
        //    } catch let error {
        //        completion?(nil, error)
        //    }
        //
        //}
        
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        guard UserDefaults.standard.spotifyAccessToken != "" else {
            return
        }
        
        createRequest(with: URL(string: Contstants.baseAPIURL + "/me"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                print(data)
                
                do {
                    //let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
                    print(result)
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    func getCurrentUserPlayingList(completion: @escaping (Result<CurrentUserPlayingList, Error>) -> Void) {
        guard UserDefaults.standard.spotifyAccessToken != "" else {
            return
        }
        
        createRequest(with: URL(string: Contstants.baseAPIURL + "/me/playlists"), type: .GET) { baseRequest in
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    //let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let result = try JSONDecoder().decode(CurrentUserPlayingList.self, from: data)
                    print("taskのresult:\(result)")
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
        
    }
    
    func getTrackItems(playlistID: String, completion: @escaping (Result<PlaylistTrackItem, Error>) -> Void) {
        guard UserDefaults.standard.spotifyAccessToken != "" else {
            return
        }
        createRequest(with: URL(string: Contstants.baseAPIURL + "/playlists/\(playlistID)/tracks"), type: .GET) { baseRequest in
            print("baseRequest:\(baseRequest)")
            let task = URLSession.shared.dataTask(with: baseRequest) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                
                do {
                    // 確認用
                    //let result = try JSONSerialization.jsonObject(with: data)
                    let result = try JSONDecoder().decode(PlaylistTrackItem.self, from: data)
                    print("taskのresult:\(result)")
                    completion(.success(result))
                }
                catch {
                    print(error.localizedDescription)
                    completion(.failure(error))
                }
                
            }
            task.resume()
        }
        
    }
    
    
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void ) {
        
        guard let apiUrl = url else { return }
        var request = URLRequest(url: apiUrl)
        
        request.setValue("Bearer \(UserDefaults.standard.spotifyAccessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = type.rawValue
        request.timeoutInterval = 30
        completion(request)
    }
    
}
