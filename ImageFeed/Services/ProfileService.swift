//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Amir on 11.08.2026.
//

import Foundation

final class ProfileService{
    static let shared = ProfileService()
    private init() {}
    private let decoder = JSONDecoder()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void){
        assert(Thread.isMainThread)
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            
            self.task = nil
            
            switch result{
            case .success(let body):
                let profile = Profile(
                    username: body.username,
                    name: [body.firstName, body.lastName]
                        .compactMap {$0}
                        .joined(separator: " "),
                    loginName: "@"+body.username,
                    bio: body.bio ?? "")
                
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Decode error:", error)
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    
    private func makeProfileRequest(token: String) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/me") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


extension ProfileService{
        private func data(
            for request: URLRequest,
            completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask{
                let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
                    DispatchQueue.main.async{
                        if let error = error{
                            completion(.failure(error))
                            return
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
