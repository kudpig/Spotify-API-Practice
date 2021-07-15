# Spotify-API-Practice
SpotifyAPIを叩いてデータを取得するサンプル

## Why

- APIを叩く練習
- OAuth2.0認証を使ったAPIの練習

リクエスト方法について、デフォルトのURLSessionとAlaomofireで使用感を比べてみたりもした。

## Preview

<img src="https://i.gyazo.com/1973c3513f956833322bc98f64b90508.gif" width="400">

## ソースコード
※ClientID等は伏せています

### AppDelegate
 
 ```swift
 import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Router.shared.showRoot(window: UIWindow(frame: UIScreen.main.bounds))
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        Router.shared.afterRedirect(url: url)
        return true
    }
    
}
 ```
 
 ### Router
 
 ```swift
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
 ```
 
 ### API
 
 ```swift
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
    let scopes = "user-read-private%20playlist-read-private%20playlist-read-collaborative"
    let redirectURI = "kudpigspotifypractice://callback"
    let stateStr = "state"
    
    enum  URLParameterName: String {
        case clientID = "client_id"
        case clientSecret = "client_secret"
        case redirectURI = "redirect_uri"
        case grantType = "grant_type"
    }
    

    let getTokenEndPoint = "https://accounts.spotify.com/api/token"
    let grantType = "authorization_code"
    
    
    
    var oAuthURL: URL {
        return URL(string: "\(base)?response_type=code&client_id=\(Contstants.clientID)&scope=\(scopes)&redirect_uri=\(redirectURI)&state=\(stateStr)&show_dialog=TRUE")!
    }
    
    func postAuthorizationCode(code: String, completion: ((SpotifyAccessTokenModel?, Error?) -> Void)? = nil) {
        
        guard let url = URL(string: getTokenEndPoint) else {
            completion?(nil, APIError.postAuthorizationCode)
            return
        }
        
        let basicAuthCode = Contstants.clientID+":"+Contstants.clientSecret
        let data = basicAuthCode.data(using: .utf8)
        guard let base64AuthCode = data?.base64EncodedString() else {
            print("base64エンコードエラー")
            completion?(nil, APIError.postAuthorizationCode)
            return
        }
        
        let parameters = [
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURI
        ]
        
        let getTokenHeaders: HTTPHeaders = [
            "Authorization": "Basic \(base64AuthCode)"
        ]
        
        AF.request(url, method: .post, parameters: parameters, headers: getTokenHeaders).responseJSON { (response) in
        
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
        
        // デフォルトのURLセッションでボディ送る場合
        /*
        var compornents = URLComponents()
        compornents.queryItems = [
            URLQueryItem(name: URLParameterName.grantType.rawValue, value: grantType),
            URLQueryItem(name: URLParameterName.code.rawValue, value: code),
            URLQueryItem(name: URLParameterName.redirectURI.rawValue, value: redirectURI)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = compornents.query?.data(using: .utf8)
        
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
        */
        
    }
    
    func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        
        guard UserDefaults.standard.spotifyAccessToken != "" else {
            return
        }
        
        guard let url = URL(string: Contstants.baseAPIURL + "/me") else {
            completion(.failure(APIError.failedToGetData))
            return
        }
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(UserDefaults.standard.spotifyAccessToken)"
        ]
        
        AF.request(url, method: .get, headers: headers).responseJSON { (response) in
            do {
                guard let _data = response.data else {
                    return
                }
                let result = try JSONDecoder().decode(UserProfile.self, from: _data)
                print(result)
                completion(.success(result))
            } catch let error {
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }
        
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    // 学習のためデフォルトのURLセッションでリクエスト送っている
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
    
    // 学習のためデフォルトのURLセッションでリクエスト送っている
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
 ```
 
 ### LoginViewController
 
 ```swift
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
 ```
 
 ### HomeViewController(認証後トップページ)
 
 ```swift
 import UIKit
import AlamofireImage

class HomeViewController: UIViewController {

    private var userItems: [UserProfile] = []
    private var currentUserPlayListsBase: [CurrentUserPlayingList] = []
    private var currentUserPlayLists: [PlayingListItem] = []
    private var playlistTrackItems: [TrackItem] = []
    private var nowPlaylistID: String = ""
    
    @IBOutlet private weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 50
        }
    }
    
    @IBOutlet private weak var userNameLabel: UILabel!
    
    @IBOutlet private weak var PlayListCollectionView: UICollectionView! {
        didSet {
            PlayListCollectionView.register(UINib(nibName: PlayingListCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: PlayingListCollectionViewCell.identifier)
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal // 横スクロール
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            let size = PlayListCollectionView.frame.height
            layout.itemSize = CGSize(width: size, height: size)
            PlayListCollectionView.collectionViewLayout = layout
            PlayListCollectionView.delegate = self
            PlayListCollectionView.dataSource = self
        }
    }
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: TrackItemTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: TrackItemTableViewCell.identifier)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tableView.isHidden = true
        fetchUserProfile()
        fetchCurrentUserPlayingList()
    }
    
    
    @IBAction private func tapLogoutButton(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "spotifyAccessTokenKey")
        Router.shared.showReStart()
    }
    
    private func fetchUserProfile() {
        API.shared.getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let model):
                self?.userItems.append(model)
                self?.userNameLabel.text = model.display_name + " のライブラリ"
                
                let images = model.images
                let imageUrl = images.first?.url
                if let url = URL(string: imageUrl ?? "") {
                    self?.userImageView.af.setImage(withURL: url)
                }
                
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        }
    }
    
    private func fetchCurrentUserPlayingList() {
        API.shared.getCurrentUserPlayingList { [weak self] result in
            
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.currentUserPlayListsBase.append(model)
                    
                    for v in model.items {
                        self?.currentUserPlayLists.append(v)
                    }
                    
                    print("プレイリスト(currentUserPlayLists)：\(String(describing: self?.currentUserPlayLists))")
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.PlayListCollectionView.reloadData()
            }
        }
    }
    
    private func fetchTrackItems() {
        guard !self.nowPlaylistID.isEmpty else {
            return
        }
        
        API.shared.getTrackItems(playlistID: self.nowPlaylistID) { [weak self] result in
            
            print("result:\(result)")
            
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    
                    for v in model.items {
                        self?.playlistTrackItems.append(v.track)
                    }
                    print("トラックアイテム(playlistTrackItems)：\(String(describing: self?.playlistTrackItems))")
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                }
                self?.tableView.reloadData()
            }
            
        }
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentUserPlayLists.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlayingListCollectionViewCell.identifier, for: indexPath) as? PlayingListCollectionViewCell else {
        return UICollectionViewCell()
        }
        
        let model = currentUserPlayLists[indexPath.item]
        cell.configure(model: model)
    
        return cell
    }
    
}


extension HomeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        playlistTrackItems.removeAll()
        
        let item = currentUserPlayLists[indexPath.item]
        let itemID = item.id
        nowPlaylistID = itemID
        // model.idをtrackのGETリクエストにつけて送る
        fetchTrackItems()
    }
}


extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistTrackItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackItemTableViewCell.identifier) as? TrackItemTableViewCell else {
            return UITableViewCell()
        }
        
        let item = playlistTrackItems[indexPath.row]
        cell.configure(model: item)
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    // didSelectRowAt
}
 ```
 
 ### Cell(プレイリスト)
 
 ```swift
 import UIKit
import AlamofireImage

class PlayingListCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String { String(describing: PlayingListCollectionViewCell.self) }
    
    @IBOutlet private weak var nameLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(model: PlayingListItem) {
        
        if !model.name.isEmpty {
            nameLabel.text = model.name
        } else {
            nameLabel.text = "名称未設定"
        }
        
        guard !model.images.isEmpty else {
            imageView.image = UIImage(named: "placeholderImage")
            return
        }
        
        nameLabel.text = model.name
        
        if let url = URL(string: model.images[0].url) {
            imageView.af.setImage(withURL: url, completion: { [weak self] response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    self?.imageView.image = UIImage(named: "placeholderImage")
                break
                }
            })
        }
    }
    
}
 ```
 ### Model(プレイリスト)
 
 ```swift
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
 ```
 
### その他
省略...
 
 
 
