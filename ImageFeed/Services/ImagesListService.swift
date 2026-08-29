//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Amir on 29.08.2026.
//

import Foundation
import SwiftKeychainWrapper

final class ImagesListService{
    var lastLoadedPage: Int?
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    private (set) var avatarUrl: String?
    private(set) var photos: [Photo] = []
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchPhotosNextPage(_ completion: @escaping (Result<[Photo], Error>) -> Void){
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeImageRequest() else {
            completion(.failure(NetworkError.codeError))
            return
        }
        
        let task = objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            self.task = nil
            
            switch result{
            case .success(let photosArray):
                let convertedPhotos = photosArray.map {self.convertedToPhoto($0)}
                self.photos = convertedPhotos
                completion(.success(convertedPhotos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeImageRequest() -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/photos?page=1&per_page=10") else { return nil }
        guard let token: String = KeychainWrapper.standard.string(forKey: "Auth token") else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


extension ImagesListService{
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


extension ImagesListService{
    private func convertedToPhoto(_ photos: PhotoResult) -> Photo{
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: photos.created_at)
        
        let size = CGSize(width: photos.width, height: photos.height)
        
        return Photo(
            id: photos.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: photos.description,
            thumbImageURL: photos.urls.thumb,
            largeImageURL: photos.urls.regular,
            isLiked: false)
    }
}
