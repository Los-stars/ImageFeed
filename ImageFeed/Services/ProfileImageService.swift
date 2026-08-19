//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Amir on 12.08.2026.
//

import Foundation
import SwiftKeychainWrapper

final class ProfileImageService{
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    private (set) var avatarURL: String?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            self.task = nil
            
            switch result{
            case .success(let body):
                let avatarURL = body.profile_image.small
                
                self.avatarURL = avatarURL
                NotificationCenter.default
                    .post(name: ProfileImageService.didChangeNotification,
                          object: self,
                          userInfo: ["URL": avatarURL])
                
                completion(.success(avatarURL))
            case .failure(let error):
                print("Decode error:", error)
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    
    private func makeProfileImageRequest(username: String) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else { return nil }
        guard let token: String = KeychainWrapper.standard.string(forKey: "Auth token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


extension ProfileImageService{
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
