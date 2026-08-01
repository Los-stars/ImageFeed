//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Amir on 06.07.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage? {
        didSet{
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let image else { return }
        
        imageView.image = image
        imageView.frame.size = image.size
        reScaleImage(image: image)
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    @IBAction func didTapBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        
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
