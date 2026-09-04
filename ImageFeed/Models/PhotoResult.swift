//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Amir on 30.08.2026.
//

struct PhotoResult: Codable{
    let id: String
    let createdAt: String
    let description: String?
    let urls: UrlsResult
    let user: User
    let width: Int
    let height: Int
    let likedByUser: Bool
    
    enum CodingKeys: String, CodingKey{
        case id
        case createdAt = "created_at"
        case description
        case urls
        case user
        case width
        case height
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Codable{
    let regular: String
    let small: String
    let thumb: String
}

struct User: Codable{
    let name: String
}
