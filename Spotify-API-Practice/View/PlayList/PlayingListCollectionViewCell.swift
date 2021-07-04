//
//  PlayingListCollectionViewCell.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/03.
//

import UIKit
import AlamofireImage

class PlayingListCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String { String(describing: PlayingListCollectionViewCell.self) }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
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
