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
}

final class API {
    
    static let shared = API()
    private init() {}
    
    struct Contstants {
        static let clientID = "clientID"
        static let clientSecret = "clientSecret"
    }
    
    let base = "https://accounts.spotify.com/authorize"
    let scopes = "user-read-private"
    let scopeTwo = "user-read-recently-played"
    let redirectURI = "kudpigspotifypractice://callback"
    let stateStr = "34fFs29kd09"
    // show_dialog=TRUE
    // ユーザーがすでにアプリを承認している場合に、再度承認するように強制するかどうかを指定します
    // trueの場合、ユーザーは自動的にはリダイレクトされず、再度アプリを承認しなければなりません(デフォルトはfalse)
    
    
    // トークン取得で使用
    // エンドポイント POST
    let getTokenEndPoint = "https://accounts.spotify.com/api/token"
    let grantType = "authorization_code"
    
    let getTokenHeaders: HTTPHeaders = [
        "Authorization": "Basic encoding_Contstants.clientID:Contstants.clientSecret"
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
        return URL(string: "\(base)?response_type=code&client_id=\(Contstants.clientID)&scope=\(scopes)+\(scopeTwo)&redirect_uri=\(redirectURI)&state=\(stateStr)&show_dialog=TRUE")!
    }
    
    func postAuthorizationCode(code: String, completion: ((SpotifyAccessTokenModel?, Error?) -> Void)? = nil) {
        
        guard let url = URL(string: getTokenEndPoint) else {
            completion?(nil, APIError.postAuthorizationCode)
            return
        }
        
        // デフォルトのURLセッションでボディ送る場合
        //var compornents = URLComponents()
        //compornents.queryItems = [
        //    URLQueryItem(name: URLParameterName.grantType.rawValue, value: grantType),
        //    URLQueryItem(name: URLParameterName.code.rawValue, value: code),
        //    URLQueryItem(name: URLParameterName.redirectURI.rawValue, value: redirectURI)
        //]
        //
        //var request = URLRequest(url: url)
        //request.httpMethod = "POST"
        //request.httpBody = compornents.query?.data(using: .utf8)
        // let task = URLSession.shared.detaTask(with: request) { data, response, error in }
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        AF.request(url, method: .post, parameters: parameters, headers: getTokenHeaders).responseJSON { (response) in
            
            print("postのレスポンス:\(response)")
            do {
                guard let _data = response.data else {
                    completion?(nil, APIError.postAuthorizationCode)
                    return
                }
                let accessToken = try JSONDecoder().decode(SpotifyAccessTokenModel.self, from: _data)
                completion?(accessToken, nil)
            } catch let error {
                completion?(nil, error)
            }
            
        }
        
    }
    
}
