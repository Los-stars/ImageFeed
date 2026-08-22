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

class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    private var estimatedProgressObservation: NSKeyValueObservation?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        webView.navigationDelegate = self
        loadAuthView()
        updateProgress()
        
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: {[weak self] _, _ in
                 guard let self else { return }
                 self.updateProgress()
             })
    }
    
    private func updateProgress(){
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView(){
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURL),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        guard let url = urlComponents.url else { return }
        
        let request = URLRequest(url: url)
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
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"}){
            return codeItem.value
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
