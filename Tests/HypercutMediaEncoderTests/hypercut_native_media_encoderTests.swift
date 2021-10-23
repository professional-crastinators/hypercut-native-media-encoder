import XCTest
@testable import HypercutMediaEncoder

final class HypercutMediaEncoderTests: XCTestCase {
  func testExtract() throws {
    let task = expectation(description: "export")
    
    let encoder = MediaConverter(filepath: URL.init(fileURLWithPath: "/Users/michaelverges/Desktop/test.mov"))
    
    encoder.getAudio { data in
      print("success")
      task.fulfill()
    }
    
    waitForExpectations(timeout: 30) { _ in
      XCTFail()
    }
  }
}
