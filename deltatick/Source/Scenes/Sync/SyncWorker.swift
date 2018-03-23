import Foundation
import RxSwift

protocol SyncWorkerLogic {
    
    func createMigrationToken(success: @escaping (MigrationTokenResponse) -> (), failure: @escaping (Error) -> ())
    func getMigrationStatusForToken(_ token: String, success: @escaping (MigrationStatusResponse.Status) -> (), failure: @escaping (Error) -> ())
}

final class SyncWorker: SyncWorkerLogic {
    
    var api = Delta.self
    
    private let disposeBag: DisposeBag
    private let dateFormatter: DateFormatter
    
    init(disposeBag: DisposeBag = DisposeBag(),
         dateFormatter: DateFormatter = DateFormatter()) {
        self.disposeBag = disposeBag
        self.dateFormatter = dateFormatter
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    func createMigrationToken(success: @escaping (MigrationTokenResponse) -> (), failure: @escaping (Error) -> ()) {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        api.createMigrationToken
            .request()
            .map(MigrationTokenResponse.self, atKeyPath: nil, using: decoder, failsOnEmptyData: true)
            .subscribe(onSuccess: { (migrationToken) in
                success(migrationToken)
            }) { (error) in
                failure(error)
            }.disposed(by: disposeBag)
    }
    
    func getMigrationStatusForToken(_ token: String, success: @escaping (MigrationStatusResponse.Status) -> (), failure: @escaping (Error) -> ()) {
        let request = MigrationStatusRequest(token: token)
        api.getMigrationStatus(request: request)
            .request()
            .map(MigrationStatusResponse.self)
            .subscribe(onSuccess: { (status) in
                success(status.status)
            }) { (error) in
                failure(error)
            }.disposed(by: disposeBag)
    }
}
