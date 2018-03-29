@testable import deltatick
import XCTest
import Cocoa

final class StatusItemControllerTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: StatusItemController!
    var mockStatusItem: MockStatusItem!
    var mockDelayHelper: MockDelayHelper!
    var mockInteractor: MockInteractor!
    var mockRouter: MockRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatusItemController()
    }
    
    // MARK: Test setup
    
    func setupStatusItemController() {
        mockStatusItem = MockStatusItem()
        mockDelayHelper = MockDelayHelper()
        sut = StatusItemController(statusItem: mockStatusItem, delayHelper: mockDelayHelper)
        mockInteractor = MockInteractor()
        sut.interactor = mockInteractor
        mockRouter = MockRouter(dataStore: mockInteractor)
        sut.router = mockRouter
    }
    
    // MARK: Tests
    
    func testFetchDataShouldCallInteractor() {
        // Given
        let expectedRequest = StatusItem.Fetch.Request()
        
        // When
        sut.fetchData()
        
        // Then
        XCTAssertTrue(mockInteractor.fetchDataCalled)
        XCTAssertEqual(mockInteractor.fetchDataRequest, expectedRequest)
    }
    
    func testDisplaySyncShouldCallDelayHelper() {
        // Given
        let viewModel = StatusItem.Sync.ViewModel()
        
        // When
        sut.displaySync(viewModel)
        
        // Then
        XCTAssertTrue(mockDelayHelper.delayCalled)
        XCTAssertEqual(mockDelayHelper.delayDelay, 0.5)
    }
    
    func testDisplaySyncShouldCallRouterAfterDelay() {
        // Given
        let viewModel = StatusItem.Sync.ViewModel()
        
        // When
        sut.displaySync(viewModel)
        mockDelayHelper.delayClosure?()
        
        // Then
        XCTAssertTrue(mockRouter.routeToSyncViewControllerCalled)
        XCTAssertTrue(mockRouter.routeToSyncViewControllerSourceButton === mockStatusItem.mockButton)
    }
    
    func testDisplayDataShouldSetStatusItemTitle() {
        // Given
        let title = "Title"
        let viewModel = StatusItem.Fetch.ViewModel(buttonTitle: title)
        
        // When
        sut.displayData(viewModel)
        
        // Then
        XCTAssertEqual(mockStatusItem.button?.title, title)
    }
    
    // MARK: Test doubles
    
    final class MockInteractor: StatusItemBusinessLogic, StatusItemDataStore {
        
        var portfolio: Portfolio?
        
        var fetchDataCalled = false
        var fetchDataRequest: StatusItem.Fetch.Request?
        func fetchData(request: StatusItem.Fetch.Request) {
            fetchDataCalled = true
            fetchDataRequest = request
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

    final class MockRouter: StatusItemRoutingLogic, StatusItemDataPassing {
        
        var dataStore: StatusItemDataStore
        
        init(dataStore: StatusItemDataStore) {
            self.dataStore = dataStore
        }
        
        var routeToSyncViewControllerCalled = false
        var routeToSyncViewControllerSourceButton: NSStatusBarButton?
        func routeToSyncViewController(sourceButton: NSStatusBarButton, popover: NSPopover) {
            routeToSyncViewControllerCalled = true
            routeToSyncViewControllerSourceButton = sourceButton
        }
    }
    
    final class MockDelayHelper: DelayHelperLogic {
        
        var delayCalled = false
        var delayDelay: Double?
        var delayClosure: (() -> ())?
        func delay(_ delay: Double, closure: @escaping () -> ()) {
            delayCalled = true
            delayDelay = delay
            delayClosure = closure
        }
    }
    
    final class MockStatusItem: NSStatusItem {
        
        var mockButton = NSStatusBarButton(title: "", target: nil, action: nil)
        override var button: NSStatusBarButton? {
            return mockButton
            
        }
    }
}
