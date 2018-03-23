import Cocoa

protocol SyncPresentationLogic {
    
    func presentMigrationTokenResponse(_ response: Sync.MigrationToken.Response)
    func presentLoadingResponse(_ response: Sync.Loading.Response)
    func presentMigrationResponse(_ response: Sync.Migration.Response)
    func presentError(_ response: Sync.Error.Response)
}

final class SyncPresenter: SyncPresentationLogic {
    
    private weak var viewController: SyncDisplayLogic?
    
    init(viewController: SyncDisplayLogic) {
        self.viewController = viewController
    }
    
    func presentMigrationTokenResponse(_ response: Sync.MigrationToken.Response) {
        let viewModel = Sync.MigrationToken.ViewModel(code: response.migrationToken.token)
        viewController?.displayMigrationToken(viewModel: viewModel)
    }
    
    func presentLoadingResponse(_ response: Sync.Loading.Response) {
        let message: String
        switch response.type {
        case .status:
            message = "sync_scan_title".ls
        case .token:
            message = "sync_initializing_title".ls
        }
        let viewModel = Sync.Loading.ViewModel(message: message)
        viewController?.displayLoadingStatus(viewModel: viewModel)
    }
    
    func presentMigrationResponse(_ response: Sync.Migration.Response) {
        switch response.status {
        case .ended:
            let viewModel = Sync.Migration.ViewModel(shouldClose: true, message: nil)
            viewController?.displayMigrationResult(viewModel: viewModel)
        case .failed:
            let viewModel = Sync.Migration.ViewModel(shouldClose: false, message: "sync_failed_title".ls)
            viewController?.displayMigrationResult(viewModel: viewModel)
        default:
            return
        }
    }
    
    func presentError(_ response: Sync.Error.Response) {
        
    }
}
