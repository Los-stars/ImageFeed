//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Amir on 19.09.2026.
//

@testable import ImageFeed
import XCTest

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol{
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func logout() {
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol{
    var presenter: ImageFeed.ProfileViewPresenterProtocol?
    var didAvatarUpdated = false
    
    func updateAvatar() {
        didAvatarUpdated = true
    }
    
    func updateProfileDetails(profile: ImageFeed.Profile) {
    }
    
    
}

final class ProfileViewTests: XCTestCase{
    func testViewControllerCallsViewDidLoad(){
        let viewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterSpy()
        viewController.presenter = profileViewPresenter
        profileViewPresenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(profileViewPresenter.viewDidLoadCalled)
    }
    
    func testUpdateAvatar(){
        let viewController = ProfileViewControllerSpy()
        let profileViewPresenter = ProfileViewPresenter()
        viewController.presenter = profileViewPresenter
        profileViewPresenter.view = viewController
        
        viewController.presenter?.viewDidLoad()
        
        XCTAssertTrue(viewController.didAvatarUpdated)
    }
}
