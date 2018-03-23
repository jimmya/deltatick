//
//  AuthenticationPlugin.swift
//  deltatick
//
//  Created by Jimmy Arts on 21/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Moya
import KeychainSwift

final class AuthenticationPlugin: PluginType {
    
    private let keychain: KeychainSwift
    
    init(keychain: KeychainSwift = KeychainSwift()) {
        self.keychain = keychain
    }
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let authToken = keychain.authToken else {
            return request
        }
        var request = request
        request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        return request
    }
}
