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
    private let skeleton = SkeletonView()
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        previewImage.layer.cornerRadius = 16
        previewImage.layer.masksToBounds = true
        
        skeleton.translatesAutoresizingMaskIntoConstraints = false
        skeleton.isUserInteractionEnabled = false
        previewImage.addSubview(skeleton)
        
        NSLayoutConstraint.activate([
            skeleton.topAnchor.constraint(equalTo: previewImage.topAnchor),
            skeleton.bottomAnchor.constraint(equalTo: previewImage.bottomAnchor),
            skeleton.leadingAnchor.constraint(equalTo: previewImage.leadingAnchor),
            skeleton.trailingAnchor.constraint(equalTo: previewImage.trailingAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        previewImage.kf.cancelDownloadTask()
        previewImage.image = nil
        skeleton.stopAnimating()
        skeleton.isHidden = true
        setState(.loading)
    }
    
    func setState(_ state: FeedCellImageState){
        switch state{
        case .loading:
            previewImage.image = nil
            dateLabel.isHidden = true
            likeButton.isHidden = true
            skeleton.isHidden = false
            skeleton.startAnimation()
        case .error:
            skeleton.stopAnimating()
            skeleton.isHidden = true
            previewImage.image = UIImage(named: "stub")
        case .finished(let image):
            skeleton.stopAnimating()
            skeleton.isHidden = true
            previewImage.image = image
            dateLabel.isHidden = false
            likeButton.isHidden = false
        }
    }
    
    func setIsLiked(isLiked: Bool){
        let imageName = isLiked ? "Like button Active" : "Like button Passive"
        likeButton.setImage(UIImage(named: imageName), for: .normal)
    }
    @IBAction func likeButtonTapped(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
