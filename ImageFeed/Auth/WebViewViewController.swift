//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Amir on 24.07.2026.
//

import UIKit
import WebKit

enum WebViewConstants{
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

protocol WebViewViewControllerProtocol: AnyObject{
    var presenter : WebViewPresenterProtocol? { get set }
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    func load(request: URLRequest)
}
class WebViewViewController: UIViewController & WebViewViewControllerProtocol{
    var presenter: WebViewPresenterProtocol?
    
    
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.accessibilityIdentifier = "UnsplashWebView"
        
        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    func load(request: URLRequest) {
        webView.load(request)
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

extension WebViewViewController{
    private func code(from navigationAction: WKNavigationAction) -> String?{
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }else{
            return nil
        }
    }
}

extension WebViewViewController: WKNavigationDelegate{
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction){
            decisionHandler(.cancel)
            delegate?.webViewController(self, didAuthenticateWithCode: code)
        }else{
            decisionHandler(.allow)
        }
    }
}
