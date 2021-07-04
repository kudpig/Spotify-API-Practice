//
//  TrackItemTableViewCell.swift
//  Spotify-API-Practice
//
//  Created by Shinichiro Kudo on 2021/07/03.
//

import UIKit
import AlamofireImage

class TrackItemTableViewCell: UITableViewCell {
    
    static var identifier: String { String(describing: TrackItemTableViewCell.self) }

    @IBOutlet weak var trackImageView: UIImageView!
    
    @IBOutlet weak var trackTitleLabel: UILabel!
    
    @IBOutlet weak var trackArtistNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(model: TrackItem) {
    
        guard !model.name.isEmpty else { return }
    
        trackTitleLabel.text = model.name
        trackArtistNameLabel.text = model.artists.first?.name
    
        guard let imageUrl = model.album.images?.first?.url else {
            trackImageView.image = UIImage(named: "placeholderImage")
            return
        }
    
        if let url = URL(string: imageUrl) {
            trackImageView.af.setImage(withURL: url, completion: { [weak self] response in
                switch response.result {
                case .success(_):
                    break
                case .failure(_):
                    self?.trackImageView.image = UIImage(named: "placeholderImage")
                break
                }
            })
        }
    
    }
    
}
