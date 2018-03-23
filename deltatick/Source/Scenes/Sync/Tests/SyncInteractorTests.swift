@testable import deltatick
import XCTest

final class SyncInteractorTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: SyncInteractor!
    var mockPresenter: MockPresenter!
    var mockWorker: MockWorker!
    var mockUserDefaults: MockUserDefaults!
    var mockDelayHelper: MockDelayHelper!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupSyncInteractor()
    }
    
    // MARK: Test setup
    
    func setupSyncInteractor() {
        mockPresenter = MockPresenter()
        mockWorker = MockWorker()
        mockUserDefaults = MockUserDefaults()
        mockDelayHelper = MockDelayHelper()
        sut = SyncInteractor(presenter: mockPresenter, worker: mockWorker, userDefaults: mockUserDefaults, delayHelper: mockDelayHelper)
    }
    
    // MARK: Tests
    
    func testRequestMigrationTokenShouldPresentLoadingResponseToken() {
        // Given
        let request = Sync.MigrationToken.Request()
        let expectedResponse = Sync.Loading.Response(type: .token)
        
        // When
        sut.requestMigrationToken(request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoadingResponseCalled)
        XCTAssertEqual(mockPresenter.presentLoadingResponseResponse, expectedResponse)
    }
    
    func testRequestMigrationTokenShouldCallWorker() {
        // Given
        let request = Sync.MigrationToken.Request()

        // When
        sut.requestMigrationToken(request)
        
        // Then
        XCTAssertTrue(mockWorker.createMigrationTokenCalled)
    }
    
    func testRequestMigrationTokenSuccessShouldPresentTokenResponse() {
        // Given
        let request = Sync.MigrationToken.Request()
        let token = MigrationTokenResponse(token: "MockToken", expiresAt: Date(timeIntervalSince1970: 123))
        let expectedResponse = Sync.MigrationToken.Response(migrationToken: token)
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        
        // Then
        XCTAssertTrue(mockPresenter.presentMigrationTokenResponseCalled)
        XCTAssertEqual(mockPresenter.presentMigrationTokenResponseResponse, expectedResponse)
    }
    
    func testRequestMigrationTokenErrorShouldPresentError() {
        // Given
        let request = Sync.MigrationToken.Request()
        let error = MockError.mock
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenFailure?(error)
        
        // Then
        XCTAssertTrue(mockPresenter.presentErrorCalled)
        XCTAssertEqual(mockPresenter.presentErrorResponse?.error as! MockError, error)
    }
    
    func testRequestMigrationTokenSuccessShouldPresentLoadingResponse() {
        // Given
        let request = Sync.MigrationToken.Request()
        let token = MigrationTokenResponse(token: "", expiresAt: Date(timeIntervalSinceNow: 15))
        let expectedResponse = Sync.Loading.Response(type: .status)
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoadingResponseCalled)
        XCTAssertEqual(mockPresenter.presentLoadingResponseResponse, expectedResponse)
    }
    
    func testRequestMigrationTokenSuccessShouldTriggerPoll() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        
        // Then
        XCTAssertTrue(mockWorker.getMigrationStatusCalled)
        XCTAssertEqual(mockWorker.getMigrationStatusToken, mockToken)
    }
    
    func testRequestMigrationTokenSuccessShouldNotTriggerPollIfTokenIsExpired() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSince1970: 0))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        
        // Then
        XCTAssertFalse(mockWorker.getMigrationStatusCalled)
    }
    
    func testRequestMigrationTokenSuccessShouldRequestMigrationTokenIfExpired() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSince1970: 0))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenCalled = false
        mockWorker.createMigrationTokenSuccess?(token)
        
        // Then
        XCTAssertTrue(mockWorker.createMigrationTokenCalled)
    }
    
    func testRequestMigrationTokenPollSuccessShouldPresentResponse() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        let expectedStatus: MigrationStatusResponse.Status = .started
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        mockWorker.getMigrationStatusSuccess?(expectedStatus)
        
        // Then
        XCTAssertTrue(mockPresenter.presentMigrationResponseCalled)
        XCTAssertEqual(mockPresenter.presentMigrationResponseResponse?.status, expectedStatus)
    }
    
    func testRequestMigrationTokenPollSuccessShouldSetSynced() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        mockWorker.getMigrationStatusSuccess?(.ended)
        
        // Then
        XCTAssertTrue(mockUserDefaults.setValueCalled)
        XCTAssertTrue(mockUserDefaults.setValueValue!)
        XCTAssertEqual(mockUserDefaults.setValueName, "hasSynced")
    }
    
    func testRequestMigrationTokenPollSuccessStatusStartedShouldScheduleSync() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        mockWorker.getMigrationStatusSuccess?(.started)
        
        // Then
        XCTAssertTrue(mockDelayHelper.delayCalled)
        XCTAssertEqual(mockDelayHelper.delayDelay, 2)
    }
    
    func testRequestMigrationTokenPollSuccessStatusStartedShouldPollStatusAfterDelay() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        mockWorker.getMigrationStatusSuccess?(.started)
        mockWorker.getMigrationStatusCalled = false
        mockWorker.getMigrationStatusToken = nil
        mockDelayHelper.delayClosure?()
        
        // Then
        XCTAssertTrue(mockWorker.getMigrationStatusCalled)
        XCTAssertEqual(mockWorker.getMigrationStatusToken, mockToken)
    }
    
    func testRequestMigrationTokenPollFailureShouldPresentError() {
        // Given
        let request = Sync.MigrationToken.Request()
        let mockToken = "MockToken"
        let token = MigrationTokenResponse(token: mockToken, expiresAt: Date(timeIntervalSinceNow: 15))
        let error = MockError.mock
        
        // When
        sut.requestMigrationToken(request)
        mockWorker.createMigrationTokenSuccess?(token)
        mockWorker.getMigrationStatusFailure?(error)
        
        // Then
        XCTAssertTrue(mockPresenter.presentErrorCalled)
        XCTAssertEqual(mockPresenter.presentErrorResponse?.error as! MockError, error)
    }
    
    // MARK: Test doubles
    
    final class MockPresenter: SyncPresentationLogic {
        
        var presentMigrationTokenResponseCalled = false
        var presentMigrationTokenResponseResponse: Sync.MigrationToken.Response?
        func presentMigrationTokenResponse(_ response: Sync.MigrationToken.Response) {
            presentMigrationTokenResponseCalled = true
            presentMigrationTokenResponseResponse = response
        }
        
        var presentLoadingResponseCalled = false
        var presentLoadingResponseResponse: Sync.Loading.Response?
        func presentLoadingResponse(_ response: Sync.Loading.Response) {
            presentLoadingResponseCalled = true
            presentLoadingResponseResponse = response
        }
        
        var presentMigrationResponseCalled = false
        var presentMigrationResponseResponse: Sync.Migration.Response?
        func presentMigrationResponse(_ response: Sync.Migration.Response) {
            presentMigrationResponseCalled = true
            presentMigrationResponseResponse = response
        }
        
        var presentErrorCalled = false
        var presentErrorResponse: Sync.Error.Response?
        func presentError(_ response: Sync.Error.Response) {
            presentErrorCalled = true
            presentErrorResponse = response
        }
    }

    final class MockWorker: SyncWorkerLogic {
        
        var createMigrationTokenCalled = false
        var createMigrationTokenSuccess: ((MigrationTokenResponse) -> ())?
        var createMigrationTokenFailure: ((Error) -> ())?
        func createMigrationToken(success: @escaping (MigrationTokenResponse) -> (), failure: @escaping (Error) -> ()) {
            createMigrationTokenCalled = true
            createMigrationTokenSuccess = success
            createMigrationTokenFailure = failure
        }
        
        var getMigrationStatusCalled = false
        var getMigrationStatusToken: String?
        var getMigrationStatusSuccess: ((MigrationStatusResponse.Status) -> ())?
        var getMigrationStatusFailure: ((Error) -> ())?
        func getMigrationStatusForToken(_ token: String, success: @escaping (MigrationStatusResponse.Status) -> (), failure: @escaping (Error) -> ()) {
            getMigrationStatusCalled = true
            getMigrationStatusToken = token
            getMigrationStatusSuccess = success
            getMigrationStatusFailure = failure
        }
    }
    
    final class MockUserDefaults: UserDefaults {
        
        var setValueCalled = false
        var setValueValue: Bool?
        var setValueName: String?
        override func set(_ value: Bool, forKey defaultName: String) {
            setValueCalled = true
            setValueValue = value
            setValueName = defaultName
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
    
    enum MockError: Error {
        case mock
    }
}

extension Sync.Loading.Response: Equatable {
    
    static public func ==(lhs: Sync.Loading.Response, rhs: Sync.Loading.Response) -> Bool {
        return lhs.type == rhs.type
    }
}

extension Sync.Migration.Response: Equatable {
    
    static public func ==(lhs: Sync.Migration.Response, rhs: Sync.Migration.Response) -> Bool {
        return lhs.status == rhs.status
    }
}

extension Sync.MigrationToken.Response: Equatable {
    
    static public func ==(lhs: Sync.MigrationToken.Response, rhs: Sync.MigrationToken.Response) -> Bool {
        return lhs.migrationToken == rhs.migrationToken
    }
}

extension MigrationTokenResponse: Equatable {
    
    static public func ==(lhs: MigrationTokenResponse, rhs: MigrationTokenResponse) -> Bool {
        return lhs.token == rhs.token && lhs.expiresAt == rhs.expiresAt
    }
}
