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
  
  func testCut() throws {
    let task = expectation(description: "export")
    
    let encoder = MediaRecoder(filepath: URL.init(fileURLWithPath: "/Users/michaelverges/Downloads/test.mov"))
    
    encoder.getCut(timecodes: [
      .init(start: 25.0, end: 30.0),
      .init(start: 125.0, end: 130.0),
      .init(start: 225.0, end: 230.0),
    ]) { url in
      print(url)
      task.fulfill()
    }
    
    waitForExpectations(timeout: 3000) { _ in
      XCTFail()
    }
  }
}
