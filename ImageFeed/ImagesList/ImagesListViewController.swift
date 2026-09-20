//
//  ImagesListViewController.swift
//  ImageFeed
//
//  Created by Amir on 03.07.2026.
//

import UIKit
import Kingfisher

enum FeedCellImageState {
    case loading
    case error
    case finished(UIImage)
}

protocol ImagesListViewControllerProtocol: AnyObject{
    var presenter: ImagesListViewPresenterProtocol? { get set }
    
    func setupTableView()
    func reloadData()
    func insertRows(at indexPaths: [IndexPath])
    func showSingleImage(at indexPath: IndexPath)
    
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    
    func setLike(at indexPath: IndexPath, isLiked: Bool)
    func reloadRow(at indexPath: IndexPath)
}
final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol{
    
    
    var presenter: ImagesListViewPresenterProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    @IBOutlet private var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if presenter == nil {
            presenter = ImagesListPresenter(imagesListService: ImagesListService())
        }
        
        presenter?.view = self
        presenter?.viewDidLoad()
    }
    
    func setupTableView() {
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    func reloadData() {
        tableView.reloadData()
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates{tableView.insertRows(at: indexPaths, with: .automatic)}
    }
    
    func showSingleImage(at indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func showLoading() {
        UIBlockingProgressHUD.show()
    }
    
    func hideLoading() {
        UIBlockingProgressHUD.dismiss()
    }
    
    func showError(_ message: String) {
        print(1)
    }
    
    func setLike(at indexPath: IndexPath, isLiked: Bool) {
        let cell = tableView.cellForRow(at: indexPath) as? ImagesListCell
        cell?.setIsLiked(isLiked: isLiked)
    }
    
    func reloadRow(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier{
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath ,
                let model = presenter?.cellModel(at: indexPath) else{
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.imageUrl = model.imageURL
        }else{
            super.prepare(for: segue, sender: sender)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ImagesListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.numberOfRows() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else { return UITableViewCell() }
        imageListCell.delegate = self

        guard let model = presenter?.cellModel(at: indexPath) else { return imageListCell }
        
        imageListCell.setState(.loading)
        imageListCell.dateLabel.text = model.date ?? ""
        imageListCell.setIsLiked(isLiked: model.isLiked)
        
        let url = URL(string: model.imageURL)
        let processor = RoundCornerImageProcessor(cornerRadius: 15)
        imageListCell.previewImage.kf.indicatorType = .none
        imageListCell.previewImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "stub"),
            options: [.processor(processor)]
        ){ [weak imageListCell] result in
            switch result{
            case .success(let value):
                imageListCell?.setState(.finished(value.image))
            case .failure(let error):
                imageListCell?.setState(.error)
            }
        }
        

        return imageListCell
    }
}

extension ImagesListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.heightForRow(at: indexPath, tableViewWidth: tableView.bounds.width) ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didSelectRowAt(at: indexPath)
    }
}

extension ImagesListViewController{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.willDisplayCell(at: indexPath)
    }
}

extension ImagesListViewController: ImagesListCellDelegate{
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.didTapLike(at: indexPath)
    }
}
