//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Amir on 14.09.2026.
//
import Foundation

protocol ImagesListViewPresenterProtocol: AnyObject{
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func numberOfRows() -> Int
    func cellModel(at indexPath: IndexPath) -> ImagesListCellModel
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat
    func didSelectRowAt(at indexPath: IndexPath)
    func willDisplayCell(at indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath)
}

final class ImagesListPresenter: NSObject, ImagesListViewPresenterProtocol{
    var view: ImagesListViewControllerProtocol?
    private let imageListService: ImagesListService
    var photos: [Photo] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    init(imagesListService: ImagesListService) {
        self.imageListService = imagesListService
    }
    
    func viewDidLoad() {
        view?.setupTableView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(photosDidChange),
            name: ImagesListService.didChangeNotification,
            object: imageListService
        )
        imageListService.fetchPhotosNextPage()
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func numberOfRows() -> Int {
        return photos.count
    }
    
    func cellModel(at indexPath: IndexPath) -> ImagesListCellModel {
        let photo = photos[indexPath.row]
        let date = photo.createdAt.map { dateFormatter.string(from: $0) }
        return ImagesListCellModel(
            imageURL: photo.largeImageURL,
            date: date,
            isLiked: photo.isLiked)
    }
    
    func heightForRow(at indexPath: IndexPath, tableViewWidth: CGFloat) -> CGFloat {
        let photo = photos[indexPath.row]
        let top = CGFloat(4)
        let left = CGFloat(16)
        let bottom = CGFloat(4)
        let right = CGFloat(16)
        let imageViewWidth = tableViewWidth - left - right
        let scale = imageViewWidth / photo.size.width
        let cellHeight = photo.size.height * scale + top + bottom
        return cellHeight
    }
    
    func didSelectRowAt(at indexPath: IndexPath) {
        view?.showSingleImage(at: indexPath)
    }
    
    func willDisplayCell(at indexPath: IndexPath) {
        if indexPath.row == photos.count - 1{
            imageListService.fetchPhotosNextPage()
        }
    }
    
    func didTapLike(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        self.view?.showLoading()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                self.view?.setLike(at: indexPath, isLiked: self.photos[indexPath.row].isLiked)
                self.view?.hideLoading()
            case .failure(let error):
                print("Ошибка изменения лайка: \(error.localizedDescription)")
                self.view?.hideLoading()
            }
        }
    }
    
    @objc func photosDidChange(){
        let oldElements = photos.count
        
        photos = imageListService.photos
        
        let newElements = photos.count
        
        let range = (oldElements..<newElements).map( {
            IndexPath(row: $0, section: 0)
        })
        
        view?.insertRows(at: range)
    }
}
