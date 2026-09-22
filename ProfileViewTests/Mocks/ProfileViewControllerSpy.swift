//
//  ProfileViewControllerSpu.swift
//  ImageFeed
//
//  Created by Amir on 22.09.2026.
//
@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol{
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var didAvatarUpdated = false
    
    func updateAvatar() {
        didAvatarUpdated = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
    }
    
    
}
