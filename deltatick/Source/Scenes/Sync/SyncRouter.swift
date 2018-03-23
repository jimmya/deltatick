import Cocoa

protocol SyncRoutingLogic {
 
}

protocol SyncDataPassing {
    var dataStore: SyncDataStore { get }
}

final class SyncRouter: SyncRoutingLogic, SyncDataPassing {
    
    private weak var viewController: SyncViewController?
    private(set) var dataStore: SyncDataStore
    
    init(viewController: SyncViewController,
         dataStore: SyncDataStore) {
        self.viewController = viewController
        self.dataStore = dataStore
    }
}
