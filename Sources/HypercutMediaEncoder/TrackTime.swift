//
//  TrackTime.swift
//  
//
//  Created by Michael Verges on 10/23/21.
//

import Foundation
import AVFoundation

struct TrackTime {
  
  var start: Double
  var end: Double
  var duration: Double
  
  var startTime: CMTime {
    .init(seconds: start, preferredTimescale: 1)
  }
  
  var endTime: CMTime {
    .init(seconds: end, preferredTimescale: 1)
  }
  
  var durationTime: CMTime {
    .init(seconds: duration, preferredTimescale: 1)
  }
  
  init(start: Double, end: Double, duration: Double) {
    self.start = start
    self.end = end
    self.duration = duration
  }
}
