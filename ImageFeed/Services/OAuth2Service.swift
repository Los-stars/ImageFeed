//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Amir on 28.07.2026.
//

import Foundation

final class OAuth2Service{
    static let shared = OAuth2Service()
    private init() {}
    
    private let networkClient: NetworkRouting = NetworkClient()
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void){
        networkClient.fetchOAuthToken(code: code, handler: completion)
    }
}
