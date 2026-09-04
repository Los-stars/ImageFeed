//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Amir on 06.07.2026.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl: String? {
        didSet{
            guard isViewLoaded else { return }
            guard let imageUrl else { return }
            let url = URL(string: imageUrl)
            imageView.kf.setImage(with: url)
        }
    }
//    var image: UIImage? {
//        didSet{
//            guard isViewLoaded else { return }
//            imageView.image = image
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("imageView:", imageView as Any)
        print("scrollView:", scrollView as Any)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        guard let imageUrl else { return }
        guard let url = URL(string: imageUrl) else { return }
        
        imageView.kf.setImage(with: url) { [weak self] result in
            guard let self else { return }
            
            switch result{
            case .success(let result):
                let image = result.image
                
                imageView.image = image
                imageView.frame.size = image.size
                reScaleImage(image: image)
            case .failure(let error):
                print("Ошибка загрузки изображения: \(error)")
            }
            
        }
        
    }
    @IBAction func didTapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }
        
        let share = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        present(share, animated: true, completion: nil)
    }
    
    func reScaleImage(image: UIImage){
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let scaleByWidth = scrollView.bounds.width / image.size.width
        let scaleByHeight = scrollView.bounds.height / image.size.height
        let coffecient = scaleByWidth < scaleByHeight ? scaleByWidth : scaleByHeight
        let scale = min(maxZoomScale, max(minZoomScale, coffecient))
        scrollView.setZoomScale(scale, animated: true)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let offsetX = (newContentSize.width - scrollView.bounds.width) / 2
        let offsetY = (newContentSize.height - scrollView.bounds.height) / 2
        scrollView.setContentOffset(CGPoint(x: offsetX, y: offsetY), animated: true)
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

extension SingleImageViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
