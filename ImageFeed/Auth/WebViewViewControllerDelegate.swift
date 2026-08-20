//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Amir on 26.07.2026.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
