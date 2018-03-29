@testable import deltatick
import XCTest
import KeychainSwift

final class StatusItemInteractorTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: StatusItemInteractor!
    var mockPresenter: MockPresenter!
    var mockWorker: MockWorker!
    var mockKeychain: MockKeychain!
    var mockUserDefaults: MockUserDefaults!
    var mockStartupHelper: MockStartupHelper!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatusItemInteractor()
        MockTimer.reset()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatusItemInteractor() {
        mockPresenter = MockPresenter()
        mockWorker = MockWorker()
        mockKeychain = MockKeychain()
        mockUserDefaults = MockUserDefaults()
        mockStartupHelper = MockStartupHelper()
        sut = StatusItemInteractor(presenter: mockPresenter,
                                   worker: mockWorker,
                                   keychain: mockKeychain,
                                   userDefaults: mockUserDefaults,
                                   startupHelper: mockStartupHelper,
                                   timerType: MockTimer.self)
    }
    
    // MARK: Tests
    
    // MARK: Fetch data
    
    func testFetchDataWithoutAuthTokenShouldCallWorker() {
        // Given
        let request = StatusItem.Fetch.Request()

        // When
        sut.fetchData(request: request)


        // Then
        XCTAssertTrue(mockWorker.registerCalled)
    }
    
    func testFetchDataWithoutAuthTokenShouldSetAuthTokenOnRegisterSuccess() {
        // Given
        let request = StatusItem.Fetch.Request()
        let mockDevice = Device(id: 1, userId: 2, deviceId: "DeviceId", token: "MockToken")
        
        // When
        sut.fetchData(request: request)
        mockWorker.registerSuccess?(mockDevice)
        
        // Then
        XCTAssertTrue(mockKeychain.setCalled)
        XCTAssertEqual(mockKeychain.setValue, mockDevice.token)
        XCTAssertEqual(mockKeychain.setKey, "authToken")
    }
    
    func testFetchDataWithoutAuthTokenShouldFetchDataOnRegisterSuccess() {
        // Given
        let request = StatusItem.Fetch.Request()
        let mockDevice = Device(id: 1, userId: 2, deviceId: "DeviceId", token: "MockToken")
        
        // When
        sut.fetchData(request: request)
        mockKeychain.mockGet = "AuthToken"
        mockWorker.registerSuccess?(mockDevice)
        
        // Then
        XCTAssertTrue(mockPresenter.presentSyncCalled)
    }
    
    func testFetchDataWithoutAuthTokenShouldCallPresenterOnFailure() {
        // Given
        let request = StatusItem.Fetch.Request()
        let mockError = MockError.mock
        
        // When
        sut.fetchData(request: request)
        mockWorker.registerFailure?(mockError)
        
        // Then
        XCTAssertTrue(mockPresenter.presentErrorCalled)
        XCTAssertEqual(mockPresenter.presentErrorResponse?.error as! MockError, mockError)
    }
    
    func testFetchDataWithSyncFalseShouldCallPresenter() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentSyncCalled)
    }
    
    func testFetchDataShouldCallWorker() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(mockWorker.getPortfolioCalled)
    }
    
    func testFetchDataShouldCallPresenter() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentLoadingIndicatorCalled)
    }
    
    func testFetchDataSuccessShouldCallPresenter() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let expectedResponse = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: .worth)
        
        // When
        sut.fetchData(request: request)
        mockWorker.getPortfolioSuccess?(portfolio)
        
        // Then
        XCTAssertTrue(mockPresenter.presentDataCalled)
        XCTAssertEqual(mockPresenter.presentDataResponse, expectedResponse)
    }
    
    func testFetchDataSuccessShouldCallPresenterWithDisplayMetricType() {
        // Given
        let metricType: MetricType = .deltaBTC24h
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        mockUserDefaults.mockIntegerResponse = ["displayMetricType": metricType.rawValue]
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let expectedResponse = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: metricType)
        
        // When
        sut.fetchData(request: request)
        mockWorker.getPortfolioSuccess?(portfolio)
        
        // Then
        XCTAssertTrue(mockPresenter.presentDataCalled)
        XCTAssertEqual(mockPresenter.presentDataResponse, expectedResponse)
    }
    
    func testFetchDataFailureShouldCallPresenter() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        let error = MockError.mock
        
        // When
        sut.fetchData(request: request)
        mockWorker.getPortfolioFailure?(error)
        
        // Then
        XCTAssertTrue(mockPresenter.presentErrorCalled)
        XCTAssertEqual(mockPresenter.presentErrorResponse?.error as! MockError, error)
    }
    
    func testFetchDataShouldScheduleTimer() {
        // Given
        let request = StatusItem.Fetch.Request()
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        mockUserDefaults.mockIntegerResponse = ["refreshInterval": 999] // Invalid enum value
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(MockTimer.scheduledTimerCalled)
        XCTAssertEqual(MockTimer.scheduledTimerRepeats, true)
        XCTAssertEqual(MockTimer.scheduledTimerInterval, RefreshInterval.oneMinute.timeInterval)
    }
    
    func testFetchDataShouldScheduleTimerWithRefreshInterval() {
        // Given
        let request = StatusItem.Fetch.Request()
        let interval: RefreshInterval = .thirtyMinutes
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        mockUserDefaults.mockIntegerResponse = ["refreshInterval": interval.rawValue]
        
        // When
        sut.fetchData(request: request)
        
        // Then
        XCTAssertTrue(MockTimer.scheduledTimerCalled)
        XCTAssertEqual(MockTimer.scheduledTimerRepeats, true)
        XCTAssertEqual(MockTimer.scheduledTimerInterval, interval.timeInterval)
    }
    
    func testFetchDataScheduledTimerFireShouldCallWorker() {
        // Given
        let request = StatusItem.Fetch.Request()
        let interval: RefreshInterval = .thirtyMinutes
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        mockUserDefaults.mockIntegerResponse = ["refreshInterval": interval.rawValue]
        
        // When
        sut.fetchData(request: request)
        mockWorker.getPortfolioCalled = false
        MockTimer.scheduledTimerBlock?(Timer())
        
        // Then
        XCTAssertTrue(mockWorker.getPortfolioCalled)
    }
    
    // MARK: Refresh interval
    
    func testUpdateRefreshIntervalShouldSetUserDefaults() {
        // Given
        let interval: RefreshInterval = .tenMinutes
        let request = StatusItem.UpdateRefreshInterval.Request(interval: interval)
        
        // When
        sut.updateRefreshInterval(request: request)
        
        // Then
        XCTAssertTrue(mockUserDefaults.setIntCalled)
        XCTAssertEqual(mockUserDefaults.setIntValue, interval.rawValue)
        XCTAssertEqual(mockUserDefaults.setIntDefaultName, "refreshInterval")
    }
    
    func testUpdateRefreshShouldScheduleTimer() {
        // Given
        let interval: RefreshInterval = .tenMinutes
        let request = StatusItem.UpdateRefreshInterval.Request(interval: interval)
        
        
        // When
        sut.updateRefreshInterval(request: request)
        
        // Then
        XCTAssertTrue(MockTimer.scheduledTimerCalled)
        XCTAssertEqual(MockTimer.scheduledTimerRepeats, true)
    }
    
    // MARK: Display metric type
    
    func testUpdateDisplayMetricTypeShouldSetUserDefaults() {
        // Given
        let metricType: MetricType = .deltaBTC24h
        let request = StatusItem.UpdateDisplayMetricType.Request(displayMetricType: metricType)
        
        // When
        sut.updateDisplayMetricType(request: request)
        
        // Then
        XCTAssertTrue(mockUserDefaults.setIntCalled)
        XCTAssertEqual(mockUserDefaults.setIntValue, metricType.rawValue)
        XCTAssertEqual(mockUserDefaults.setIntDefaultName, "displayMetricType")
    }
    
    func testUpdateDisplayMetricShouldCallPresenterIfPortfolioNotNil() {
        // Given
        let metricType: MetricType = .deltaBTC24h
        let request = StatusItem.UpdateDisplayMetricType.Request(displayMetricType: metricType)
        
        mockKeychain.mockGet = "AuthToken"
        mockUserDefaults.mockBoolResponse = ["hasSynced": true]
        mockUserDefaults.mockIntegerResponse = ["displayMetricType": metricType.rawValue]
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let expectedResponse = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: metricType)
        sut.fetchData(request: StatusItem.Fetch.Request())
        mockWorker.getPortfolioSuccess?(portfolio)
        mockPresenter.presentDataCalled = false
        mockPresenter.presentDataResponse = nil
        
        // When
        sut.updateDisplayMetricType(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentDataCalled)
        XCTAssertEqual(mockPresenter.presentDataResponse, expectedResponse)
    }
    
    func testUpdateDisplayMetricShouldNotCallPresenterIfPortfolioNil() {
        // Given
        let metricType: MetricType = .deltaBTC24h
        let request = StatusItem.UpdateDisplayMetricType.Request(displayMetricType: metricType)
        
        // When
        sut.updateDisplayMetricType(request: request)
        
        // Then
        XCTAssertFalse(mockPresenter.presentDataCalled)
    }
    
    // MARK: Auto startup
    
    func testUpdateAutoStartupShouldCallStartupHelper() {
        // Given
        let value = true
        let request = StatusItem.UpdateAutoStartup.Request(autoStartup: value)
        
        // When
        sut.updateAutoStartup(request: request)
        
        // Then
        XCTAssertTrue(mockStartupHelper.setAutoStartupEnabledCalled)
        XCTAssertEqual(mockStartupHelper.setAutoStartupEnabledEnabled, value)
    }
    
    // MARK: Request sync
    
    func testRequestSyncShouldCallPresenter() {
        // Given
        let request = StatusItem.Sync.Request()
        let expectedResponse = StatusItem.Sync.Response()
        
        // When
        sut.requestSync(request: request)
        
        // Then
        XCTAssertTrue(mockPresenter.presentSyncCalled)
        XCTAssertEqual(mockPresenter.presentSyncResponse, expectedResponse)
    }
    
    // MARK: Request reset
    
    func testRequestResetShouldDeleteAuthToken() {
        // Given
        let request = StatusItem.Reset.Request()
        
        // When
        sut.requestReset(request: request)
        
        // Then
        XCTAssertTrue(mockKeychain.deleteCalled)
        XCTAssertEqual(mockKeychain.deleteKey, "authToken")
    }
    
    func testRequestResetShouldSetHasSyncedFalse() {
        // Given
        let request = StatusItem.Reset.Request()
        
        // When
        sut.requestReset(request: request)
        
        // Then
        XCTAssertTrue(mockUserDefaults.setBoolCalled)
        XCTAssertEqual(mockUserDefaults.setBoolDefaultName, "hasSynced")
        XCTAssertEqual(mockUserDefaults.setBoolValue, false)
    }
    
    func testRequestResetShouldCallProviderRegister() {
        // Given
        let request = StatusItem.Reset.Request()
        
        // When
        sut.requestReset(request: request)
        
        // Then
        XCTAssertTrue(mockWorker.registerCalled)
    }
    
    // MARK: Test doubles
    
    enum MockError: Error {
        case mock
    }
    
    final class MockPresenter: StatusItemPresentationLogic {
        
        var presentLoadingIndicatorCalled = false
        func presentLoadingIndicator() {
            presentLoadingIndicatorCalled = true
        }
        
        var presentSyncCalled = false
        var presentSyncResponse: StatusItem.Sync.Response?
        func presentSync(_ response: StatusItem.Sync.Response) {
            presentSyncCalled = true
            presentSyncResponse = response
        }
        
        var presentErrorCalled = false
        var presentErrorResponse: StatusItem.Error.Response?
        func presentError(_ response: StatusItem.Error.Response) {
            presentErrorCalled = true
            presentErrorResponse = response
        }
        
        var presentDataCalled = false
        var presentDataResponse: StatusItem.Fetch.Response?
        func presentData(_ response: StatusItem.Fetch.Response) {
            presentDataCalled = true
            presentDataResponse = response
        }
    }

    final class MockWorker: StatusItemWorkerLogic {
        
        var getPortfolioCalled = false
        var getPortfolioSuccess: ((Portfolio) -> ())?
        var getPortfolioFailure: ((Error) -> ())?
        func getPortfolio(success: @escaping (Portfolio) -> (), failure: @escaping (Error) -> ()) {
            getPortfolioCalled = true
            getPortfolioSuccess = success
            getPortfolioFailure = failure
        }
        
        var registerCalled = false
        var registerSuccess: ((Device) -> ())?
        var registerFailure: ((Error) -> ())?
        func register(success: @escaping (Device) -> (), failure: @escaping (Error) -> ()) {
            registerCalled = true
            registerSuccess = success
            registerFailure = failure
        }
    }
    
    final class MockKeychain: KeychainSwift {
        
        var setCalled = false
        var setValue: String?
        var setKey: String?
        override func set(_ value: String, forKey key: String, withAccess access: KeychainSwiftAccessOptions?) -> Bool {
            setCalled = true
            setValue = value
            setKey = key
            return true
        }

        var deleteCalled = false
        var deleteKey: String?
        override func delete(_ key: String) -> Bool {
            deleteCalled = true
            deleteKey = key
            return true
        }
        
        var mockGet: String?
        override func get(_ key: String) -> String? {
            return mockGet
        }
    }
    
    final class MockUserDefaults: UserDefaults {
        
        var mockBoolResponse: [String: Bool] = [:]
        override func bool(forKey defaultName: String) -> Bool {
            return mockBoolResponse[defaultName] ?? false
        }
        
        var mockIntegerResponse: [String: Int] = [:]
        override func integer(forKey defaultName: String) -> Int {
            return mockIntegerResponse[defaultName] ?? 0
        }
        
        var setIntCalled = false
        var setIntValue: Int?
        var setIntDefaultName: String?
        override func set(_ value: Int, forKey defaultName: String) {
            setIntCalled = true
            setIntValue = value
            setIntDefaultName = defaultName
        }
        
        var setBoolCalled = false
        var setBoolValue: Bool?
        var setBoolDefaultName: String?
        override func set(_ value: Bool, forKey defaultName: String) {
            setBoolCalled = true
            setBoolValue = value
            setBoolDefaultName = defaultName
        }
    }
    
    final class MockStartupHelper: AutoStartupHelperLogic {
        
        var autoStartupEnabled: Bool = false
        
        var setAutoStartupEnabledCalled = false
        var setAutoStartupEnabledEnabled: Bool?
        func setAutoStartupEnabled(_ enabled: Bool) {
            setAutoStartupEnabledCalled = true
            setAutoStartupEnabledEnabled = enabled
        }
    }
    
    final class MockTimer: Timer {
        
        static func reset() {
            scheduledTimerCalled = false
            scheduledTimerInterval = nil
            scheduledTimerRepeats = nil
            scheduledTimerBlock = nil
        }
        
        static var scheduledTimerCalled = false
        static var scheduledTimerInterval: TimeInterval?
        static var scheduledTimerRepeats: Bool?
        static var scheduledTimerBlock: ((Timer) -> ())?
        override class func scheduledTimer(withTimeInterval interval: TimeInterval, repeats: Bool, block: @escaping (Timer) -> Swift.Void) -> Timer {
            scheduledTimerCalled = true
            scheduledTimerInterval = interval
            scheduledTimerRepeats = repeats
            scheduledTimerBlock = block
            return Timer()
        }
    }
}
