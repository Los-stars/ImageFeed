//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Amir on 12.09.2026.
//

import Foundation

final class AuthHelper: AuthHelperProtocol{
    
    // MARK: - Properties
    
    private let configuration: AuthConfiguration
    
    // MARK: - Initialization
    
    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }
    
    // MARK: - Public function
    
    func authRequest() -> URLRequest? {
        guard let url = authUrl() else { return nil }
        return URLRequest(url: url)
    }
    
    func code(from url: URL) -> String? {
        guard let urlComponents = URLComponents(string: url.absoluteString),
              urlComponents.path == "/oauth/authorize/native",
              let items = urlComponents.queryItems,
              let codeItem = items.first(where: { $0.name == "code" }) else {
            return nil
        }
        
        return codeItem.value
    }
        
    func authUrl() -> URL?{
        guard var urlComponents = URLComponents(string: configuration.authURLString) else { return nil }
        
        urlComponents.queryItems = [
               URLQueryItem(name: "client_id", value: configuration.accessKey),
               URLQueryItem(name: "redirect_uri", value: configuration.redirectURL),
               URLQueryItem(name: "response_type", value: "code"),
               URLQueryItem(name: "scope", value: configuration.accessScope)
           ]
        
        return urlComponents.url
    }
}
