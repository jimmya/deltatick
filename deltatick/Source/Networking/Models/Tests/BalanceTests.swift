import XCTest
@testable import deltatick

final class BalanceTests: XCTestCase {
    
    func testValueForMetricWorthShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.worth)
        
        // Then
        XCTAssertEqual(balance.worth, value)
    }
    
    func testValueForMetricWorthBTCShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.worthBTC)
        
        // Then
        XCTAssertEqual(balance.worthInBtc, value)
    }
    
    func testValueForMetricDeltaShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.delta)
        
        // Then
        XCTAssertEqual(balance.deltaTotal, value)
    }
    
    func testValueForMetricDelta24hShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.delta24h)
        
        // Then
        XCTAssertEqual(balance.delta24h, value)
    }
    
    func testValueForMetricDeltaBTCShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.deltaBTC)
        
        // Then
        XCTAssertEqual(balance.deltaTotalInBtc, value)
    }
    
    func testValueForMetricDeltaBTC24hShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.deltaBTC24h)
        
        // Then
        XCTAssertEqual(balance.delta24hInBtc, value)
    }
    
    func testValueForMetricPercentageShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.percentage)
        
        // Then
        XCTAssertEqual(balance.percentageTotal, value)
    }
    
    func testValueForMetricPercentage24hShouldReturnRightValue() {
        // Given
        let balance = TestHelper.loadMock(as: Portfolio.self, fromFile: "Portfolio")!.object!.balance
        
        // When
        let value = balance.valueForMetricType(.percentage24h)
        
        // Then
        XCTAssertEqual(balance.percentage24h, value)
    }
}
