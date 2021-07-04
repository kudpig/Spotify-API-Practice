//
//  HomeViewController.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/06/29.
//

import UIKit
import AlamofireImage

class HomeViewController: UIViewController {

    private var userItems: [UserProfile] = []
    private var currentUserPlayListsBase: [CurrentUserPlayingList] = []
    private var currentUserPlayLists: [PlayingListItem] = []
    private var playlistTrackItems: [TrackItem] = []
    private var nowPlaylistID: String = ""
    
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 50
        }
    }
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var PlayListCollectionView: UICollectionView! {
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
    
    @IBOutlet weak var tableView: UITableView! {
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
    
    private func fetchUserProfile() {
        API.shared.getCurrentUserProfile { [weak self] result in
            
            DispatchQueue.main.async {
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
    } // ユーザープロフィール取得ここまで
    
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
    } // プレイリスト取得ここまで
    
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
    } // TrackItemsの取得ここまで
    
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
    // cell.didSelect
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
