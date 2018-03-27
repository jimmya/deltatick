@testable import deltatick
import XCTest

final class StatusItemWorkerTests: XCTestCase {
    
    // MARK: Subject under test
    
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
        sut = StatusItemWorker()
    }
    
    // MARK: Tests
    
    func testSomething() {
        // Given
        
        // When
        
        // Then
    }
    
    // MARK: Test doubles
    
}
