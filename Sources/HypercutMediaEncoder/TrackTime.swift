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
    .init(seconds: start * 1000, preferredTimescale: 1000)
  }
  
  var endTime: CMTime {
    .init(seconds: end * 1000, preferredTimescale: 1000)
  }
  
  var durationTime: CMTime {
    .init(seconds: duration * 1000, preferredTimescale: 1000)
  }
  
  init(start: Double, end: Double, duration: Double) {
    self.start = start
    self.end = end
    self.duration = duration
  }
}
