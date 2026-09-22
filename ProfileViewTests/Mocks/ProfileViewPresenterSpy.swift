//
//  ProfileViewPresenterSpy.swift
//  ImageFeed
//
//  Created by Amir on 22.09.2026.
//
@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol{
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalledCount = 0
    
    func logout() {
    }
    
    func viewDidLoad() {
        viewDidLoadCalledCount += 1
    }
    
    
}
