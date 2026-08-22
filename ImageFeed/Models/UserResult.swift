//
//  UserResult.swift
//  ImageFeed
//
//  Created by Amir on 12.08.2026.
//

struct UserResult: Codable{
    let profileImage: ProfileImage
    
    enum CodingKeys: String, CodingKey{
        case profileImage = "profile_image"
    }
}


struct ProfileImage: Codable{
    let small: String
}
