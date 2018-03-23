import Foundation
import Cocoa

protocol StatusItemRoutingLogic {
    
    func routeToSyncViewController(sourceButton: NSStatusBarButton)
}

protocol StatusItemDataPassing {
    var dataStore: StatusItemDataStore { get }
}

final class StatusItemRouter: StatusItemRoutingLogic, StatusItemDataPassing {
    
    private weak var controller: StatusItemController?
    private(set) var dataStore: StatusItemDataStore
    
    private var popover: NSPopover?
    
    init(controller: StatusItemController,
         dataStore: StatusItemDataStore) {
        self.controller = controller
        self.dataStore = dataStore
    }

    // MARK: Routing
    
    func routeToSyncViewController(sourceButton: NSStatusBarButton) {
        let viewController = SyncViewController()
        viewController.delegate = self
        popover = NSPopover()
        popover?.contentViewController = viewController
        popover?.behavior = .applicationDefined
        popover?.show(relativeTo: sourceButton.bounds, of: sourceButton, preferredEdge: .maxY)
    }
}

extension StatusItemRouter: SyncViewControllerDelegate {
    
    func viewControllerRequestsPoverClose(_ viewController: SyncViewController) {
        popover?.close()
        popover = nil
        controller?.fetchData()
    }
}
