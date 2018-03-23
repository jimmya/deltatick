//
//  deltatickTests.swift
//  deltatickTests
//
//  Created by Jimmy Arts on 21/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import XCTest
@testable import deltatick
import Moya

final class TestHelper {
    
    static func loadMock<T: Decodable>(as type: T.Type, fromFile file: String, decoder: JSONDecoder = JSONDecoder()) -> (object: T?, data: Data)? {
        guard let path = Bundle(for: TestHelper.self).path(forResource: file, ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path))
            else {
                return nil
        }
        do {
            let object = try decoder.decode(T.self, from: data)
            return (object: object, data: data)
        } catch {
            print(error)
        }
        return (object: nil, data: data)
    }
}

extension MoyaProvider {
    
    final class func requestFailureEndpointMapping(for target: Target) -> Endpoint {
        return Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { .networkResponse(400, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }
}
