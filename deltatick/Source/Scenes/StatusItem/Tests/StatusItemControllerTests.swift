@testable import deltatick
import XCTest

final class StatusItemControllerTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: StatusItemController!
    var mockInteractor: MockInteractor!
    var mockRouter: MockRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatusItemController()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatusItemController() {
        sut = StatusItemController()
        mockInteractor = MockInteractor()
        sut.interactor = mockInteractor
        mockRouter = MockRouter(dataStore: mockInteractor)
        sut.router = mockRouter
    }
    
    // MARK: Tests
    
    func testSomething() {
        // Given
        
        
        // When
        
        
        // Then
        
    }
    
    // MARK: Test doubles
    
    final class MockInteractor: StatusItemBusinessLogic, StatusItemDataStore {
        
        var portfolio: Portfolio?
        
        func fetchData(request: StatusItem.Fetch.Request) {
            
        }
        
        func updateRefreshInterval(request: StatusItem.UpdateRefreshInterval.Request) {
            
        }
        
        func updateDisplayMetricType(request: StatusItem.UpdateDisplayMetricType.Request) {
            
        }
        
        func updateAutoStartup(request: StatusItem.UpdateAutoStartup.Request) {
            
        }
        
        func requestSync(request: StatusItem.Sync.Request) {
            
        }
    }

    final class MockRouter: StatusItemRoutingLogic, StatusItemDataPassing {
        
        var dataStore: StatusItemDataStore
        
        init(dataStore: StatusItemDataStore) {
            self.dataStore = dataStore
        }
        
        func routeToOverviewViewController(source: NSStatusBarButton) {
            
        }
        
        func routeToSyncViewController(sourceButton: NSStatusBarButton) {
            
        }
    }
    
}
