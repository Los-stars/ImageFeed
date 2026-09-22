//
//  ProfileViewPresenterProtocol.swift
//  ImageFeed
//
//  Created by Amir on 14.09.2026.
//

import Foundation

protocol ProfileViewPresenterProtocol: AnyObject{
    var view: ProfileViewControllerProtocol? { get set }
    func logout()
    func viewDidLoad()
}

final class ProfileViewPresenter: NSObject, ProfileViewPresenterProtocol{
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                view?.updateAvatar()
            }
        
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }
        view?.updateAvatar()
    }
    deinit{
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    
    func logout() {
        self.profileLogoutService.logout()
    }
    
    
}
