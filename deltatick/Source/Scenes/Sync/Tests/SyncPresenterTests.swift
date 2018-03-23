@testable import deltatick
import XCTest

final class SyncPresenterTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: SyncPresenter!
    var mockViewController: MockViewController!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSyncPresenter()
    }
    
    // MARK: Test setup
    
    func setupSyncPresenter() {
        mockViewController = MockViewController()
        sut = SyncPresenter(viewController: mockViewController)
    }
    
    // MARK: Tests
    
    func testPresentMigrationTokenShouldCallViewControllerWithToken() {
        // Given
        let mockToken = "MockToken"
        let migrationTokenResponse = MigrationTokenResponse(token: mockToken, expiresAt: Date())
        let response = Sync.MigrationToken.Response(migrationToken: migrationTokenResponse)
        let expectedViewModel = Sync.MigrationToken.ViewModel(code: mockToken)
        
        // When
        sut.presentMigrationTokenResponse(response)
        
        // Then
        XCTAssertTrue(mockViewController.displayMigrationTokenCalled)
        XCTAssertEqual(mockViewController.displayMigrationTokenViewModel, expectedViewModel)
    }
    
    func testPresentLoadingResponseStatusShouldCallViewControllerWithRightMessage() {
        // Given
        let response = Sync.Loading.Response(type: .status)
        let expectedViewModel = Sync.Loading.ViewModel(message: "Scan the QR code")
        
        // When
        sut.presentLoadingResponse(response)
        
        // Then
        XCTAssertTrue(mockViewController.displayLoadingStatusCalled)
        XCTAssertEqual(mockViewController.displayLoadingStatusViewModel, expectedViewModel)
    }
    
    func testPresentLoadingResponseTokenShouldCallViewControllerWithRightMessage() {
        // Given
        let response = Sync.Loading.Response(type: .token)
        let expectedViewModel = Sync.Loading.ViewModel(message: "Initializing sync")
        
        // When
        sut.presentLoadingResponse(response)
        
        // Then
        XCTAssertTrue(mockViewController.displayLoadingStatusCalled)
        XCTAssertEqual(mockViewController.displayLoadingStatusViewModel, expectedViewModel)
    }
    
    func testPresentMigrationResponseEndedShouldCallViewControllerWithShouldClose() {
        // Given
        let response = Sync.Migration.Response(status: .ended)
        let expectedViewModel = Sync.Migration.ViewModel(shouldClose: true, message: nil)
        
        // When
        sut.presentMigrationResponse(response)
        
        // Then
        XCTAssertTrue(mockViewController.displayMigrationResultCalled)
        XCTAssertEqual(mockViewController.displayMigrationResultViewModel, expectedViewModel)
    }
    
    func testPresentMigrationResponseFailedShouldCallViewControllerWithMessage() {
        // Given
        let response = Sync.Migration.Response(status: .failed)
        let expectedViewModel = Sync.Migration.ViewModel(shouldClose: false, message: "Sync failed")
        
        // When
        sut.presentMigrationResponse(response)
        
        // Then
        XCTAssertTrue(mockViewController.displayMigrationResultCalled)
        XCTAssertEqual(mockViewController.displayMigrationResultViewModel, expectedViewModel)
    }
    
    func testPresentMigrationResponseStartedShouldNotCallViewController() {
        // Given
        let response = Sync.Migration.Response(status: .started)
        
        // When
        sut.presentMigrationResponse(response)
        
        // Then
        XCTAssertFalse(mockViewController.displayMigrationResultCalled)
    }
    
    // MARK: Test doubles
    
    final class MockViewController: SyncDisplayLogic {
        
        var displayMigrationTokenCalled = false
        var displayMigrationTokenViewModel: Sync.MigrationToken.ViewModel?
        func displayMigrationToken(viewModel: Sync.MigrationToken.ViewModel) {
            displayMigrationTokenCalled = true
            displayMigrationTokenViewModel = viewModel
        }
        
        var displayLoadingStatusCalled = false
        var displayLoadingStatusViewModel: Sync.Loading.ViewModel?
        func displayLoadingStatus(viewModel: Sync.Loading.ViewModel) {
            displayLoadingStatusCalled = true
            displayLoadingStatusViewModel = viewModel
        }
        
        var displayMigrationResultCalled = false
        var displayMigrationResultViewModel: Sync.Migration.ViewModel?
        func displayMigrationResult(viewModel: Sync.Migration.ViewModel) {
            displayMigrationResultCalled = true
            displayMigrationResultViewModel = viewModel
        }
    }
    
}

extension Sync.MigrationToken.ViewModel: Equatable {
    
    public static func ==(lhs: Sync.MigrationToken.ViewModel, rhs: Sync.MigrationToken.ViewModel) -> Bool {
        return lhs.code == rhs.code
    }
}

extension Sync.Loading.ViewModel: Equatable {
    
    public static func ==(lhs: Sync.Loading.ViewModel, rhs: Sync.Loading.ViewModel) -> Bool {
        return lhs.message == rhs.message
    }
}

extension Sync.Migration.ViewModel: Equatable {
    
    public static func ==(lhs: Sync.Migration.ViewModel, rhs: Sync.Migration.ViewModel) -> Bool {
        return lhs.shouldClose == rhs.shouldClose && lhs.message == rhs.message
    }
}
