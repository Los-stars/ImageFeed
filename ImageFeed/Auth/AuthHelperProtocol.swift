//
//  AuthHelperProtocol.swift
//  ImageFeed
//
//  Created by Amir on 22.09.2026.
//
import Foundation

protocol AuthHelperProtocol{
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}
