//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Amir on 01.07.2026.
//

import XCTest
import SwiftKeychainWrapper

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments += ["-uitest_reset_keychain"]
        app.launch()
    }
    
    func testAuth() throws{
        app.buttons["Authenticate"].tap()
        let webView = app.webViews["UnsplashWebView"]
        webView.waitForExistence(timeout: 5)
                
        let loginTextField = webView.descendants(matching: .textField).element
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        
        sleep(5)
        
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()
        
        app.keyboards.buttons["Go"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        sleep(10)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws{
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.waitForExistence(timeout: 25)
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.waitForExistence(timeout: 25)
        cellToLike.buttons.element.tap()
        sleep(5)
        cellToLike.buttons.element.tap()
        sleep(5)
        cellToLike.tap()
        sleep(5)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButton = app.buttons["NavBackButton"]
        navBackButton.tap()
    }
    
    func testProfile() throws{
        let firstTab = app.tabBars.buttons.element(boundBy: 1)
        firstTab.tap()
        
        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)
        
        app.buttons["logoutButton"].tap()
        let alert = app.alerts.firstMatch
        alert.buttons["Да"].tap()
    }
}
