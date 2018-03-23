@testable import deltatick
import XCTest

final class SyncViewControllerTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: SyncViewController!
    var mockInteractor: MockInteractor!
    var mockRouter: MockRouter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSyncViewController()
    }
    
    // MARK: Test setup
    
    func setupSyncViewController() {
        sut = SyncViewController()
        mockInteractor = MockInteractor()
        sut.interactor = mockInteractor
        mockRouter = MockRouter(dataStore: mockInteractor)
        sut.router = mockRouter
    }
    
    // MARK: Tests
    
    func testViewDidAppearShouldRequestMigrationToken() {
        // When
        sut.viewDidAppear()
        
        // Then
        XCTAssertTrue(mockInteractor.requestMigrationTokenCalled)
    }
    
    func testDisplayMigrationTokenShouldSetCodeImage() {
        // Given
        _ = sut.view
        let viewModel = Sync.MigrationToken.ViewModel(code: "Code")
        
        // When
        sut.displayMigrationToken(viewModel: viewModel)
        
        // Then
        XCTAssertNotNil(sut.codeImageView.image)
    }
    
    func testDisplayLoadingStatusShouldSetLoadingLabel() {
        // Given
        _ = sut.view
        let message = "MockMessage"
        let viewModel = Sync.Loading.ViewModel(message: message)
        
        // When
        sut.displayLoadingStatus(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.loadingLabel.stringValue, message)
    }
    
    func testDisplayLoadingStatusShouldStartLoadingAnimation() {
        // Given
        _ = sut.view
        let mockProgressIndicator = MockProgressIndicator()
        sut.progressIndicator = mockProgressIndicator
        let message = "MockMessage"
        let viewModel = Sync.Loading.ViewModel(message: message)
        
        // When
        sut.displayLoadingStatus(viewModel: viewModel)
        
        // Then
        XCTAssertTrue(mockProgressIndicator.startAnimationCalled)
        XCTAssertTrue(mockProgressIndicator.startAnimationSender as AnyObject === sut)
    }
    
    func testDisplayMigrationResultShouldCloseShouldCallDelegate() {
        // Given
        _ = sut.view
        let mockDelegate = MockDelegate()
        sut.delegate = mockDelegate
        let viewModel = Sync.Migration.ViewModel(shouldClose: true, message: nil)
        
        // When
        sut.displayMigrationResult(viewModel: viewModel)
        
        // Then
        XCTAssertTrue(mockDelegate.requestsPopoverCloseCalled)
        XCTAssertTrue(mockDelegate.requestsPopoverCloseViewController === sut)
    }
    
    func testDisplayMigrationResultShouldCloseShouldNotStopLoadingAnimation() {
        // Given
        _ = sut.view
        let mockProgressIndicator = MockProgressIndicator()
        sut.progressIndicator = mockProgressIndicator
        let viewModel = Sync.Migration.ViewModel(shouldClose: true, message: "Message")
        
        // When
        sut.displayMigrationResult(viewModel: viewModel)
        
        // Then
        XCTAssertFalse(mockProgressIndicator.stopAnimationCalled)
    }
    
    func testDisplayMigrationResultMessageShouldDisplayMessage() {
        // Given
        _ = sut.view
        let mockMessage = "MockMessage"
        let viewModel = Sync.Migration.ViewModel(shouldClose: false, message: mockMessage)
        
        // When
        sut.displayMigrationResult(viewModel: viewModel)
        
        // Then
        XCTAssertEqual(sut.loadingLabel.stringValue, mockMessage)
    }
    
    func testDisplayMigrationResultMessageShouldStopLoadingAnimation() {
        // Given
        _ = sut.view
        let mockProgressIndicator = MockProgressIndicator()
        sut.progressIndicator = mockProgressIndicator
        let viewModel = Sync.Migration.ViewModel(shouldClose: false, message: "")
        
        // When
        sut.displayMigrationResult(viewModel: viewModel)
        
        // Then
        XCTAssertTrue(mockProgressIndicator.stopAnimationCalled)
        XCTAssertTrue(mockProgressIndicator.stopAnimationSender as AnyObject === sut)
    }
    
    // MARK: Test doubles
    
    final class MockDelegate: SyncViewControllerDelegate {
        
        var requestsPopoverCloseCalled = false
        var requestsPopoverCloseViewController: SyncViewController?
        func viewControllerRequestsPoverClose(_ viewController: SyncViewController) {
            requestsPopoverCloseCalled = true
            requestsPopoverCloseViewController = viewController
        }
    }
    
    final class MockProgressIndicator: NSProgressIndicator {
        
        var startAnimationCalled = false
        var startAnimationSender: Any?
        override func startAnimation(_ sender: Any?) {
            startAnimationCalled = true
            startAnimationSender = sender
        }
        
        var stopAnimationCalled = false
        var stopAnimationSender: Any?
        override func stopAnimation(_ sender: Any?) {
            stopAnimationCalled = true
            stopAnimationSender = sender
        }
    }
    
    final class MockInteractor: SyncBusinessLogic, SyncDataStore {
        
        var migrationStatus: MigrationStatusResponse.Status?
        
        var requestMigrationTokenCalled = false
        func requestMigrationToken(_ request: Sync.MigrationToken.Request) {
            requestMigrationTokenCalled = true
        }
    }

    final class MockRouter: NSObject, SyncRoutingLogic, SyncDataPassing {
        
        var dataStore: SyncDataStore
        
        init(dataStore: SyncDataStore) {
            self.dataStore = dataStore
        }
        
        func routeToClose() {
            
        }
    }
}
