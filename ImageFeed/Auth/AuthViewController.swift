//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Amir on 24.07.2026.
//

import UIKit

final class AuthViewController: UIViewController{
    private let oauth2Service = OAuth2Service.shared
    private let networkClient = NetworkClient()
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier{
            guard let webViewController = segue.destination as? WebViewViewController else {
                assertionFailure("Failed to prepare for \(showWebViewSegueIdentifier)")
                return
            }
            webViewController.delegate = self
        }else{
            super.prepare(for: segue, sender: sender)
        }
    }
    
    private func configureBackButton(){
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backwardButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.titleView?.tintColor = UIColor(resource: .ypBlack)
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

extension AuthViewController: WebViewViewControllerDelegate{
    func webViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true)
        
        networkClient.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            
            switch result{
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                print("OAuth error:", error)
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}

extension AuthViewController{
    private func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        networkClient.fetchOAuthToken(code: code) { result in
            completion(result)
        }
    }
}
