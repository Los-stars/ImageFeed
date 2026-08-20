//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Amir on 28.07.2026.
//

import Foundation

protocol NetworkRouting{
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void)
}

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

class NetworkClient: NetworkRouting{
    private let tokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void){
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.dataTask(with: request) { data, response , error in
            if let error = error{
                
                print("Network error:", error)
                
                DispatchQueue.main.async{
                    handler(.failure(error))
                }
                return
            }
            guard let data else {
                DispatchQueue.main.async {
                    handler(.failure(NetworkError.codeError))
                }
                return
            }
            guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else{
                
                print(String(data: data, encoding: .utf8) ?? "No response body")
                
                DispatchQueue.main.async{
                    handler(.failure(NetworkError.codeError))
                }
                return
            }
            
            do{
                let body = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                self.tokenStorage.token = body.access_token
                
                DispatchQueue.main.async{
                    handler(.success(body.access_token))
                }
            }catch{
                print("Decode error:", error)
                DispatchQueue.main.async{
                    handler(.failure(error))
                }
            }
            
        }
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest?{
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let authTokenUrl = urlComponents.url else{
            return nil
        }
        
        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post.rawValue
        
        return request
    }
}
