//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Amir on 31.08.2026.
//
import Foundation
import WebKit
import SwiftKeychainWrapper

final class ProfileLogoutService{
    static let shared = ProfileLogoutService()
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private init() {}
    
    func logout(){
        cleanCookies()
        cleanToken()
        cleanProfile()
        cleanProfileImage()
        switchRootViewControllerToSplashViewController()
    }
    
    private func cleanCookies(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanProfile(){
        profileService.clearProfile()
    }
    
    private func cleanProfileImage(){
        profileImageService.cleanProfileImage()
    }
    
    private func cleanToken(){
        KeychainWrapper.standard.remove(forKey: "Auth token")
    }
    
    private func switchRootViewControllerToSplashViewController(){
        guard let windowsScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive || $0.activationState == .foregroundInactive}) as? UIWindowScene,
              let windows = windowsScene.windows.first else{
            assertionFailure("Invalid window configuration")
            return
        }
        
        let splashViewController = SplashViewController()
        
        windows.rootViewController = splashViewController
        windows.makeKeyAndVisible()
    }
}
