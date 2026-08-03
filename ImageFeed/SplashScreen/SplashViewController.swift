//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Amir on 31.07.2026.
//

import UIKit

class SplashViewController: UIViewController{
    
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil{
            switchToTabBarController()
        }else{
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAuthenticationScreenSegueIdentifier"{
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers.first as? AuthViewController else {
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
                  }
            
            viewController.delegate = self
        }else{
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController:  AuthViewControllerDelegate{
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
    }
}
