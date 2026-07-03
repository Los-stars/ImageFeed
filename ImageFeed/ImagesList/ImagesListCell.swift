//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Amir on 03.07.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell{
    @IBOutlet weak var previewImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    static let reuseIdentifier = "ImagesListCell"
}
