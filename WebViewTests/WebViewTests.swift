//
//  WebViewTests.swift
//  WebViewTests
//
//  Created by Amir on 12.09.2026.
//

@testable import ImageFeed
import XCTest

final class WebViewPresenterSpy: WebViewPresenterProtocol{
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewViewControllerSpy: WebViewViewControllerProtocol{
    var presenter: WebViewPresenterProtocol?
    var didLoadRequestCalled: Bool = false
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
    
    func load(request: URLRequest) {
        didLoadRequestCalled = true
    }
    
    
}

final class WebViewTests: XCTestCase{
    func testViewControllerCallsViewDidLoad(){
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyBoard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let webViewPresenter = WebViewPresenterSpy()
        viewController.presenter = webViewPresenter
        webViewPresenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(webViewPresenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest(){
        let viewController = WebViewViewControllerSpy()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        viewController.presenter = webViewPresenter
        webViewPresenter.view = viewController
        
        webViewPresenter.viewDidLoad()
        
        XCTAssertTrue(viewController.didLoadRequestCalled)
    }
    
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne(){
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1.0
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        XCTAssertEqual(shouldHideProgress, true)
    }
    
    
    func testAuthHelperAuthURL(){
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let url = authHelper.authUrl()
        let urlString = url?.absoluteString
        
        XCTAssertTrue(((urlString?.contains(configuration.authURLString)) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.accessKey)) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.redirectURL)) != nil))
        XCTAssertTrue(((urlString?.contains("code")) != nil))
        XCTAssertTrue(((urlString?.contains(configuration.accessScope)) != nil))
    }
    
    func testCodeFromURL(){
        let authHelper = AuthHelper()
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native") else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "code", value: "test code")
        ]
        
        guard let url = urlComponents.url else { return }
        
        let code = authHelper.code(from: url)
        
        XCTAssertEqual(code, "test code")
    }
}
