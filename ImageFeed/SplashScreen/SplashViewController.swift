//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Amir on 31.07.2026.
//

import UIKit
import SwiftKeychainWrapper

class SplashViewController: UIViewController{
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUIElements()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token: String = KeychainWrapper.standard.string(forKey: "Auth token"){
            fetchProfile(token: token)
        }else{
            switchToAuthViewController()
        }
    }
    
    private func switchToTabBarController(){
        guard let windowsScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive || $0.activationState == .foregroundInactive}) as? UIWindowScene,
              let windows = windowsScene.windows.first else{
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabbarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TabBarViewController")
        
        windows.rootViewController = tabbarController
        windows.makeKeyAndVisible()
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


extension SplashViewController{
    
    func switchToAuthViewController(){
        guard let vc = UIStoryboard(name: "Main", bundle: .main)
                .instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
            else { return }
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

extension SplashViewController:  AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let token = KeychainWrapper.standard.string(forKey: "Auth token") else { return }
            self?.fetchProfile(token: token)
        }
    }
    
    private func fetchProfile(token: String){
        
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self else { return }
            
            UIBlockingProgressHUD.dismiss()
            switch result{
            case .success( let profile):
                self.profileImageService.fetchProfileImageURL(username: profile.username) {_ in}
                self.switchToTabBarController()
            case .failure:
                break
            }
        }
    }
}


extension SplashViewController{
    func setupUIElements(){
        self.view.backgroundColor = UIColor.ypBlack
        let logoImage = UIImage(named: "Vector launch screen logo")
        let logoImageView = UIImageView(image: logoImage)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 77),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
