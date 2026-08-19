//
//  UserResult.swift
//  ImageFeed
//
//  Created by Amir on 12.08.2026.
//

struct UserResult: Codable{
    var profile_image: ProfileImage
}


struct ProfileImage: Codable{
    var small: String
}
