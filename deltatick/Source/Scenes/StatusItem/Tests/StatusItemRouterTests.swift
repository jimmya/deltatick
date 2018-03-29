import XCTest
@testable import deltatick
import Cocoa

final class StatusItemRouterTests: XCTestCase {
    
    let mockInteractor = MockInteractor()
    let controller = StatusItemController()
    let mockDataSource = MockDataSource()
    var sut: StatusItemRouter!
    
    override func setUp() {
        super.setUp()
        controller.interactor = mockInteractor
        sut = StatusItemRouter(controller: controller, dataStore: mockDataSource)
    }
    
    func testRouteToSyncViewControllerShouldShowPopover() {
        // Given
        let button = NSStatusBarButton(title: "", target: nil, action: nil)
        button.bounds = NSRect(x: 25, y: 25, width: 50, height: 50)
        let mockPopover = MockPopover()
        
        // When
        sut.routeToSyncViewController(sourceButton: button, popover: mockPopover)
        
        // Then
        XCTAssertTrue(mockPopover.showCalled)
        XCTAssertEqual(mockPopover.showPositioningRect, button.bounds)
        XCTAssertEqual(mockPopover.showPositioningView, button)
        XCTAssertEqual(mockPopover.showPreferredEdge, .maxY)
    }
    
    func testViewControllerRequestsCloseShouldClosePopover() {
        // Given
        let mockPopover = MockPopover()
        sut.routeToSyncViewController(sourceButton: NSStatusBarButton(title: "", target: nil, action: nil), popover: mockPopover)
        let viewController = SyncViewController()
        
        // When
        sut.viewControllerRequestsPoverClose(viewController)
        
        // Then
        XCTAssertTrue(mockPopover.closeCalled)
    }
    
    func testViewControllerRequestsCloseShouldFetchData() {
        // Given
        let mockPopover = MockPopover()
        sut.routeToSyncViewController(sourceButton: NSStatusBarButton(title: "", target: nil, action: nil), popover: mockPopover)
        let viewController = SyncViewController()
        
        // When
        sut.viewControllerRequestsPoverClose(viewController)
        
        // Then
        XCTAssertTrue(mockInteractor.fetchDataCalled)
    }
    
    // MARK: Test doubles
    
    final class MockDataSource: StatusItemDataStore {
        var portfolio: Portfolio?
    }
    
    final class MockPopover: NSPopover {
        
        var showCalled = false
        var showPositioningRect: NSRect?
        var showPositioningView: NSView?
        var showPreferredEdge: NSRectEdge?
        override func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge) {
            showCalled = true
            showPositioningRect = positioningRect
            showPositioningView = positioningView
            showPreferredEdge = preferredEdge
        }
        
        var closeCalled = false
        override func close() {
            closeCalled = true
        }
    }
    
    final class MockInteractor: StatusItemBusinessLogic {
        
        var fetchDataCalled = false
        func fetchData(request: StatusItem.Fetch.Request) {
            fetchDataCalled = true
        }
        
        func updateRefreshInterval(request: StatusItem.UpdateRefreshInterval.Request) {
            
        }
        
        func updateDisplayMetricType(request: StatusItem.UpdateDisplayMetricType.Request) {
            
        }
        
        func updateAutoStartup(request: StatusItem.UpdateAutoStartup.Request) {
            
        }
        
        func requestSync(request: StatusItem.Sync.Request) {
            
        }
        
        func requestReset(request: StatusItem.Reset.Request) {
            
        }
    }
}
