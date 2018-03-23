//
//  DeltaAPI.swift
//  deltatick
//
//  Created by Jimmy Arts on 21/03/2018.
//  Copyright © 2018 Jimmy. All rights reserved.
//

import Foundation
import Moya
import RxSwift

enum Delta {
    case register(request: RegisterRequest)
    case createMigrationToken
    case getMigrationStatus(request: MigrationStatusRequest)
    case overviews
    case getPortfolio
    
    static var provider = MoyaProvider<Delta>(plugins: [authenticationPlugin])
    static var mockDataClosure: ((Delta) -> (Data))?
    static private let authenticationPlugin = AuthenticationPlugin()
}

extension Delta: TargetType {
    
    func request() -> PrimitiveSequence<SingleTrait, Response> {
        return Delta.provider.rx.request(self).filterSuccessfulStatusCodes()
    }
    
    var baseURL: URL { return URL(string: "https://api.getdelta.io")! }
    
    var path: String {
        switch self {
        case .register:
            return "/device/register"
        case .createMigrationToken:
            return "/device/create-migration-token"
        case .getMigrationStatus:
            return "/device/migration-token-status"
        case .overviews:
            return "/portfolio/overviews"
        case .getPortfolio:
            return "/portfolio"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .register, .createMigrationToken, .getMigrationStatus:
            return .post
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var parameters: [String : Any]? {
        switch self {
        case .getPortfolio:
            return ["getGraphData": 0, "graphPeriod": "1D"]
        default:
            return nil
        }
    }
    
    var task: Task {
        switch self {
        case .register(let request):
            return .requestJSONEncodable(request)
        case .createMigrationToken:
            let request = MigrationTokenRequest(type: .sync)
            return .requestJSONEncodable(request)
        case .getMigrationStatus(let request):
            return .requestJSONEncodable(request)
        default:
            if let parameters = parameters {
                return .requestParameters(parameters: parameters, encoding: URLEncoding.methodDependent)
            }
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        if let mockDataClosure = Delta.mockDataClosure {
            return mockDataClosure(self)
        }
        return Data()
    }
}
