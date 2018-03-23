import Foundation

protocol SyncBusinessLogic {
    
    func requestMigrationToken(_ request: Sync.MigrationToken.Request)
}

protocol SyncDataStore {
    
    var migrationStatus: MigrationStatusResponse.Status? { get }
}

final class SyncInteractor: SyncBusinessLogic, SyncDataStore {
    
    private(set) var migrationStatus: MigrationStatusResponse.Status? {
        didSet {
            guard let status = migrationStatus else { return }
            if status == .started {
                delayHelper.delay(2, closure: { [weak self] in
                    self?.pollStatus()
                })
            } else if status == .ended {
                userDefaults.hasSynced = true
            }
            presenter.presentMigrationResponse(Sync.Migration.Response(status: status))
        }
    }
    
    private let presenter: SyncPresentationLogic
    private let worker: SyncWorkerLogic
    private let userDefaults: UserDefaults
    private let delayHelper: DelayHelperLogic
    
    private var migrationToken: MigrationTokenResponse?
    
    init(presenter: SyncPresentationLogic, 
         worker: SyncWorkerLogic = SyncWorker(),
         userDefaults: UserDefaults = UserDefaults.standard,
         delayHelper: DelayHelperLogic = DelayHelper()) {
        self.presenter = presenter
        self.worker = worker
        self.userDefaults = userDefaults
        self.delayHelper = delayHelper
    }
    
    func requestMigrationToken(_ request: Sync.MigrationToken.Request) {
        presenter.presentLoadingResponse(Sync.Loading.Response(type: .token))
        worker.createMigrationToken(success: { [weak self] (token) in
            let response = Sync.MigrationToken.Response(migrationToken: token)
            self?.migrationToken = token
            self?.presenter.presentMigrationTokenResponse(response)
            self?.pollStatus()
        }) { [weak self] (error) in
            self?.presenter.presentError(Sync.Error.Response(error: error))
        }
    }
}

private extension SyncInteractor {
    
    func pollStatus() {
        guard let token = migrationToken else { return }
        if Date().timeIntervalSince(token.expiresAt) > 0 {
            requestMigrationToken(Sync.MigrationToken.Request())
            return
        }
        presenter.presentLoadingResponse(Sync.Loading.Response(type: .status))
        worker.getMigrationStatusForToken(token.token, success: { [weak self] (status) in
            self?.migrationStatus = status
        }) { [weak self] (error) in
            self?.presenter.presentError(Sync.Error.Response(error: error))
        }
    }
}
