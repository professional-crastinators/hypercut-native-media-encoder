import XCTest
@testable import HypercutMediaEncoder
import HypercutFoundation

final class HypercutMediaEncoderTests: XCTestCase {
  func testExtract() throws {
    let task = expectation(description: "export")
    
    let encoder = MediaConverter(filepath: URL.init(fileURLWithPath: "/Users/michaelverges/Downloads/test.mov"))
    
    encoder.getAudio { data in
      print("success")
      task.fulfill()
    }
    
    waitForExpectations(timeout: 30) { _ in
      XCTFail()
    }
  }
}
