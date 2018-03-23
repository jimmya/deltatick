import Foundation
import RxSwift
import Moya

protocol StatusItemWorkerLogic {
    
    func getPortfolio(success: @escaping (Portfolio) -> (), failure: @escaping (Error) -> ())
    func register(success: @escaping (Device) -> (), failure: @escaping (Error) -> ())
}

final class StatusItemWorker: StatusItemWorkerLogic {
    
    var api = Delta.self
    
    private let uuid: UUID
    private let processInfo: ProcessInfo
    private let host: Host
    private let locale: Locale
    private let timeZone: TimeZone
    private let disposeBag: DisposeBag
    
    init(uuid: UUID = UUID(),
         processInfo: ProcessInfo = ProcessInfo.processInfo,
         host: Host = Host.current(),
         locale: Locale = Locale.current,
         timeZone: TimeZone = TimeZone.current,
         disposeBag: DisposeBag = DisposeBag()) {
        self.uuid = uuid
        self.processInfo = processInfo
        self.host = host
        self.locale = locale
        self.timeZone = timeZone
        self.disposeBag = disposeBag
    }
    
    func getPortfolio(success: @escaping (Portfolio) -> (), failure: @escaping (Error) -> ()) {
        api.getPortfolio
            .request()
            .map(Portfolio.self)
            .subscribe(onSuccess: { (portfolio) in
                success(portfolio)
            }) { (error) in
                failure(error)
            }.disposed(by: disposeBag)
    }
    
    func register(success: @escaping (Device) -> (), failure: @escaping (Error) -> ()) {
        let systemName = ProcessInfo.processInfo.operatingSystemVersionString
        let name = Host.current().name ?? "Unknown"
        let currency = Locale.current.currencyCode ?? "UNK"
        let registerRequest = RegisterRequest(deviceId: uuid.uuidString, name: name, systemName: systemName, appVersion: "1.0.0", currency: currency, timezone: TimeZone.current.identifier)
        api.register(request: registerRequest)
            .request()
            .map(RegisterResponse.self)
            .subscribe(onSuccess: { (registerResponse) in
                success(registerResponse.device)
            }) { (error) in
                failure(error)
            }.disposed(by: disposeBag)
    }
}
