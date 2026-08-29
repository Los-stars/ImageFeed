//
//  Photo.swift
//  ImageFeed
//
//  Created by Amir on 29.08.2026.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Codable{
    let id: String
    let created_at: String
    let description: String
    let urls: UrlsResult
    let user: User
    let width: Int
    let height: Int
}

struct UrlsResult: Codable{
    let regular: String
    let small: String
    let thumb: String
}

struct User: Codable{
    let name: String
}
