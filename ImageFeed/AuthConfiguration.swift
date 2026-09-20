//
//  Constants.swift
//  ImageFeed
//
//  Created by Amir on 24.07.2026.
//

enum Constants {
    static let accessKey = "oeuYHrDk1qAdXcDJUthlYWlhVrTTyOU6Yuxr5igovDU"
    static let secretKey = "pQbs_ttA1acP4WB-brcdo550fmP_ssQKI2X6qPw10IY"
    static let redirectURL = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration{
    let accessKey: String
    let secretKey: String
    let redirectURL: String
    let accessScope: String
    let defaultBaseURLString: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURL: String, accessScope: String, defaultBaseURLString: String, unsplashAuthorizeURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURL = redirectURL
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = unsplashAuthorizeURLString
    }
    
    static var standard: AuthConfiguration{
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURL: Constants.redirectURL,
            accessScope: Constants.accessScope,
            defaultBaseURLString: Constants.defaultBaseURLString,
            unsplashAuthorizeURLString: Constants.unsplashAuthorizeURLString)
    }
}
