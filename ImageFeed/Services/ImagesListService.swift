//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Amir on 29.08.2026.
//

import Foundation
import SwiftKeychainWrapper

final class ImagesListService{
    var lastLoadedPage: Int = 0
    private let decoder = JSONDecoder()
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    private var lastLike: Bool?
    private(set) var photos: [Photo] = []
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private enum NetworkError: Error {
        case codeError
    }
    
    func fetchPhotosNextPage(){
        assert(Thread.isMainThread)
        
        guard task == nil else{
            return
        }
        
        let nextPage = lastLoadedPage + 1
        guard let request = makeImageRequest(page: nextPage) else {
            return
        }
                
        let task = objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            
            self.task = nil
            
            switch result{
            case .success(let photosArray):
                let convertedPhotos = photosArray.map {self.convertedToPhoto($0)}
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: convertedPhotos)
                    self.lastLoadedPage = nextPage
                NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                }
            case .failure(let error):
                print("Ошибка загрузки страницы \(nextPage): \(error.localizedDescription)")
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeImageRequest(page: Int) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page)&per_page=10") else { return nil }
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


extension ImagesListService{
    private func convertedToPhoto(_ photos: PhotoResult) -> Photo{
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: photos.createdAt)
        
        let size = CGSize(width: photos.width, height: photos.height)
        
        return Photo(
            id: photos.id,
            size: size,
            createdAt: createdAt,
            welcomeDescription: photos.description,
            thumbImageURL: photos.urls.thumb,
            largeImageURL: photos.urls.regular,
            isLiked: photos.likedByUser)
    }
}

extension ImagesListService{
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void){
        assert(Thread.isMainThread)
        
        guard lastLike != isLike else {
            return
        }
        
        self.task = nil
        
        task?.cancel()
        lastLike = isLike
        
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else { return }
        
        let task = data(for: request) { [weak self] result in
            switch result{
            case .success:
                guard let self else { return }
                
                self.task = nil
                self.lastLike = nil
                
                if let index = self.photos.firstIndex(where: { $0.id == photoId }){
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        isLiked: !photo.isLiked)
                    self.photos[index] = newPhoto
                }
                
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest?{
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else { return nil}
        guard let token: String = KeychainWrapper.standard.string(forKey: "Auth token") else { return nil}
        var request = URLRequest(url: url)
        
        if isLike{
            request.httpMethod = HTTPMethod.post.rawValue
        }else{
            request.httpMethod = HTTPMethod.delete.rawValue
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
