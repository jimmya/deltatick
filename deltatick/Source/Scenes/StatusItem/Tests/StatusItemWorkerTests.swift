@testable import deltatick
import XCTest
import Moya

private let uuid = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"

final class StatusItemWorkerTests: XCTestCase {
    
    // MARK: Subject under test
    
    let mockUUID = UUID(uuidString: uuid)!
    let mockProcessInfo = MockProcessInfo()
    let mockHost = MockHost()
    let mockTimeZone = TimeZone(identifier: "Europe/Amsterdam")!
    let mockLocale = Locale(identifier: "en_NL")
    let mockProvider = MockProvider(stubClosure: MoyaProvider.immediatelyStub)
    var sut: StatusItemWorker!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatusItemWorker()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatusItemWorker() {
        sut = StatusItemWorker(uuid: mockUUID, processInfo: mockProcessInfo, host: mockHost, locale: mockLocale, timeZone: mockTimeZone)
        sut.api.provider = mockProvider
    }
    
    // MARK: Tests
    
    func testGetPortfolioShouldCallProvider() {
        // When
        sut.getPortfolio(success: { (_) in
            
        }) { (_) in
            
        }
        
        // Then
        XCTAssertTrue(mockProvider.getPortfolioCalled)
    }
    
    func testGetPortfolioSuccessShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        let mock = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!
        sut.api.mockDataClosure = { target in
            return mock.data
        }
        
        // When
        var portfolio: Portfolio?
        sut.getPortfolio(success: { (responsePortfolio) in
            portfolio = responsePortfolio
            expect.fulfill()
        }) { (_) in
            
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertEqual(portfolio, mock.object)
        }
    }
    
    func testGetPortfolioFailureShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        sut.api.provider = MockProvider(endpointClosure: MoyaProvider.requestFailureEndpointMapping, stubClosure: MoyaProvider.immediatelyStub)
        
        // When
        var error: Error?
        sut.getPortfolio(success: { (_) in
            
        }) { (responseError) in
            error = responseError
            expect.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(error)
        }
    }
    
    func testRegisterShouldCallProvider() {
        // Given
        mockHost.mockName = "MockName"
        mockProcessInfo.mockOperatingSystemVersionString = "12.0.1"
        let expectedRequest = RegisterRequest(deviceId: uuid, name: mockHost.mockName!, systemName: mockProcessInfo.mockOperatingSystemVersionString!, appVersion: "1.0.0", currency: "EUR", timezone: "Europe/Amsterdam")
        
        // When
        sut.register(success: { (_) in
            
        }) { (_) in
            
        }
        
        // Then
        XCTAssertTrue(mockProvider.registerCalled)
        XCTAssertEqual(expectedRequest, mockProvider.registerRequest)
    }
    
    func testRegisterSuccessShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        let mock = TestHelper.loadMock(as: RegisterResponse.self, fromFile: "RegisterResponse")!
        sut.api.mockDataClosure = { target in
            return mock.data
        }
        
        // When
        var device: Device?
        sut.register(success: { (responseDevice) in
            device = responseDevice
            expect.fulfill()
        }) { (_) in
            
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertEqual(device, mock.object?.device)
        }
    }
    
    func testRegisterFailureShouldCallCompletion() {
        // Given
        let expect = expectation(description: "Completion")
        sut.api.provider = MockProvider(endpointClosure: MoyaProvider.requestFailureEndpointMapping, stubClosure: MoyaProvider.immediatelyStub)
        
        // When
        var error: Error?
        sut.register(success: { (_) in
            
        }) { (responseError) in
            error = responseError
            expect.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 1) { (_) in
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: Test doubles
    
    final class MockProvider: MoyaProvider<Delta> {
        
        var getPortfolioCalled = false
        var registerCalled = false
        var registerRequest: RegisterRequest?
        var getMigrationStatusCalled = false
        var getMigrationStatusRequest: MigrationStatusRequest?
        override func request(_ target: Delta, callbackQueue: DispatchQueue?, progress: ProgressBlock?, completion: @escaping Completion) -> Cancellable {
            switch target {
            case .getPortfolio:
                getPortfolioCalled = true
            case .register(let request):
                registerCalled = true
                registerRequest = request
            default:
                break
            }
            return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: completion)
        }
    }
    
    final class MockProcessInfo: ProcessInfo {
        
        var mockOperatingSystemVersionString: String?
        override var operatingSystemVersionString: String {
            return mockOperatingSystemVersionString ?? ""
        }
    }
    
    final class MockHost: Host {
        
        var mockName: String?
        override var name: String? {
            return mockName
        }
    }
}
