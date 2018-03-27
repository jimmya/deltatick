@testable import deltatick
import XCTest

final class StatusItemPresenterTests: XCTestCase {
    
    // MARK: Subject under test
    
    var sut: StatusItemPresenter!
    var mockController: MockController!
    var locale: Locale!
    var mockNumberFormatter: MockNumberFormatter!
    
    // MARK: Test lifecycle
    
    override func setUp() {
        super.setUp()
        setupStatusItemPresenter()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // MARK: Test setup
    
    func setupStatusItemPresenter() {
        mockController = MockController()
        locale = Locale(identifier: "en_NL")
        mockNumberFormatter = MockNumberFormatter()
        sut = StatusItemPresenter(controller: mockController, numberFormatter: mockNumberFormatter, locale: locale)
    }
    
    // MARK: Tests
    
    func testPresentLoadingIndicatorShouldCallController() {
        // Given
        let expectedViewModel = StatusItem.Fetch.ViewModel(buttonTitle: "Loading")
        
        // When
        sut.presentLoadingIndicator()
    
        // Then
        XCTAssertTrue(mockController.displayDataCalled)
        XCTAssertEqual(mockController.displayDataViewModel, expectedViewModel)
    }
    
    func testPresentSyncShouldCallController() {
        // Given
        let response = StatusItem.Sync.Response()
        let expectedViewModel = StatusItem.Sync.ViewModel()
        
        // When
        sut.presentSync(response)
        
        // Then
        XCTAssertTrue(mockController.displaySyncCalled)
        XCTAssertEqual(mockController.displaySyncViewModel, expectedViewModel)
    }
    
    func testPresentDataWithBTCDisplayMetricTypeShouldCallController() {
        // Given
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: .deltaBTC)
        let expectedViewModel = StatusItem.Fetch.ViewModel(buttonTitle: "₿0,24")
        
        // When
        sut.presentData(response)
        
        // Then
        XCTAssertTrue(mockController.displayDataCalled)
        XCTAssertEqual(mockController.displayDataViewModel, expectedViewModel)
    }
    
    func testPresentDataWithPercentageDisplayMetricTypeShouldCallController() {
        // Given
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: .percentage)
        let expectedViewModel = StatusItem.Fetch.ViewModel(buttonTitle: "12.50%")
        
        // When
        sut.presentData(response)
        
        // Then
        XCTAssertTrue(mockController.displayDataCalled)
        XCTAssertEqual(mockController.displayDataViewModel, expectedViewModel)
    }
    
    func testPresentDataWithFiatDisplayMetricTypeShouldCallController() {
        // Given
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: .worth)
        let expectedViewModel = StatusItem.Fetch.ViewModel(buttonTitle: "€1.500,50")
        
        // When
        sut.presentData(response)
        
        // Then
        XCTAssertTrue(mockController.displayDataCalled)
        XCTAssertEqual(mockController.displayDataViewModel, expectedViewModel)
    }
    
    func testPresentDataUnknownValueShouldCallController() {
        // Given
        mockNumberFormatter.shouldCallSuper = false
        let portfolio = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!
        let response = StatusItem.Fetch.Response(portfolio: portfolio, displayMetricType: .worth)
        let expectedViewModel = StatusItem.Fetch.ViewModel(buttonTitle: "UNK")
        
        // When
        sut.presentData(response)
        
        // Then
        XCTAssertTrue(mockController.displayDataCalled)
        XCTAssertEqual(mockController.displayDataViewModel, expectedViewModel)
    }
    
    // MARK: Test doubles
    
    final class MockController: StatusItemDisplayLogic {
        
        var displayDataCalled = false
        var displayDataViewModel: StatusItem.Fetch.ViewModel?
        func displayData(_ viewModel: StatusItem.Fetch.ViewModel) {
            displayDataCalled = true
            displayDataViewModel = viewModel
        }
        
        var displaySyncCalled = false
        var displaySyncViewModel: StatusItem.Sync.ViewModel?
        func displaySync(_ viewModel: StatusItem.Sync.ViewModel) {
            displaySyncCalled = true
            displaySyncViewModel = viewModel
        }
    }
    
    final class MockNumberFormatter: NumberFormatter {
        
        var shouldCallSuper = true
        var stringFromNumberValue: String?
        override func string(from number: NSNumber) -> String? {
            if shouldCallSuper {
                return super.string(from: number)
            }
            return stringFromNumberValue
        }
    }
}
