//
//  NetworkClient.swift
//  ImageFeed
//
//  Created by Amir on 28.07.2026.
//

import Foundation
import SwiftKeychainWrapper

protocol NetworkRouting{
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void)
}

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum AuthServiceError: Error {
    case invalidRequest
}

class NetworkClient: NetworkRouting{
    private let decoder = JSONDecoder()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchOAuthToken(code: String, handler: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        guard lastCode != code else{
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            handler(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }
            
            self.task = nil
            self.lastCode = nil
            
            switch result{
            case .success(let body):
                let isSuccess = KeychainWrapper.standard.set(body.accessToken, forKey: "Auth token")
                guard isSuccess else { return }
                handler(.success(body.accessToken))
            case .failure(let error):
                handler(.failure(error))
            }
        }
        self.task = task
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
    
extension NetworkClient{
        private func data(
            for request: URLRequest,
            completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask{
                let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                    DispatchQueue.main.async{
                        if let error = error{
                            completion(.failure(error))
                        }
                        
                        guard let data = data else {
                            completion(.failure(NetworkError.codeError))
                            return
                        }
                        
                        guard let response = response as? HTTPURLResponse, 200..<300 ~= response.statusCode else{
                            print(String(data: data, encoding: .utf8) ?? "No response body")
                            completion(.failure(NetworkError.codeError))
                            return
                        }
                        
                        completion(.success(data))
                    }
                }
                return task
            }
        
        func objectTask<T: Decodable>(
            for request: URLRequest,
            completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask{
                let decoder = JSONDecoder()
                let task = data(for: request) { result in
                    switch result{
                    case .success(let data):
                        do{
                            let object = try decoder.decode(T.self, from: data)
                            completion(.success(object))
                        }
                        catch{
                            print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                return task
            }
    }
