//
//  ProfileViewTests.swift
//  ProfileViewTests
//
//  Created by Amir on 19.09.2026.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase{
    func testViewControllerCallsViewDidLoad(){
        let viewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenterSpy()
        viewController.presenter = profileViewPresenter
        profileViewPresenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertEqual(profileViewPresenter.viewDidLoadCalledCount, 1)
    }
    
    func testPresenterCallsUpdateAvatarWhenViewDidLoad(){
        let viewController = ProfileViewControllerSpy()
        let profileViewPresenter = ProfileViewPresenter()
        viewController.presenter = profileViewPresenter
        profileViewPresenter.view = viewController
        
        viewController.presenter?.viewDidLoad()
        
        XCTAssertTrue(viewController.didAvatarUpdated)
    }
}
