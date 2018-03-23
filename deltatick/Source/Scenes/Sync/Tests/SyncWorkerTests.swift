@testable import deltatick
import XCTest
import Moya

final class SyncWorkerTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: SyncWorker!
    var mockProvider: MockProvider!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        mockProvider = MockProvider(stubClosure: MoyaProvider.immediatelyStub)
        setupSyncWorker()
    }
    
    // MARK: Test setup
    
    func setupSyncWorker() {
        sut = SyncWorker()
        sut.api.provider = mockProvider
    }
    
    // MARK: Tests
    
    func testCreateMigrationTokenShouldCallProvider() {
        // When
        sut.createMigrationToken(success: { (_) in
            
        }) { (_) in
            
        }
        
        // Then
        XCTAssertTrue(mockProvider.createMigrationTokenCalled)
    }
    
    func testCreateMigrationTokenSuccessShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let mock = TestHelper.loadMock(as: MigrationTokenResponse.self, fromFile: "CreateMigrationToken", decoder: decoder)
        sut.api.mockDataClosure = { _ in
            return mock!.data
        }
        
        // When
        var responseToken: MigrationTokenResponse?
        sut.createMigrationToken(success: { (response) in
            responseToken = response
            expect.fulfill()
        }) { (_) in
            
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertEqual(responseToken, mock?.object)
        }
    }
    
    func testCreateMigrationTokenErrorShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        sut.api.provider = MockProvider(endpointClosure: MoyaProvider.requestFailureEndpointMapping)
        
        // When
        var responseError: Error?
        sut.createMigrationToken(success: { (_) in
            
        }) { (error) in
            responseError = error
            expect.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(responseError)
        }
    }
    
    // MARK: Test doubles
    
    final class MockProvider: MoyaProvider<Delta> {
        
        var createMigrationTokenCalled = false
        var getMigrationStatusCalled = false
        var getMigrationStatusRequest: MigrationStatusRequest?
        override func request(_ target: Delta, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable {
            switch target {
            case .createMigrationToken:
                createMigrationTokenCalled = true
            case .getMigrationStatus(let request):
                getMigrationStatusCalled = true
                getMigrationStatusRequest = request
            default:
                break
            }
            return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        }
    }
}
