//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Amir on 28.07.2026.
//

struct OAuthTokenResponseBody: Codable{
    let access_token: String
    let token_type: String
    let scope: String
    let created_at: Int
}
