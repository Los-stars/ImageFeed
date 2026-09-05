//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Amir on 03.07.2026.
//

import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell{
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        previewImage.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool){
        let imageName = isLiked ? "Like button Active" : "Like button Passive"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
