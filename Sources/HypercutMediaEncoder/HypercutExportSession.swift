//
//  HypercutExportSession.swift
//  
//
//  Created by Michael Verges on 10/23/21.
//

import Foundation
import HypercutFoundation

public struct HypercutExportConfiguration {
  public var pauseSpeed: CGFloat = 0.7
  public var phraseSpeed: CGFloat = 0.0
  public var playbackSpeed: CGFloat = 0.0
}

public struct HypercutExportSession {
  
  public var phrases: [Phrase]
  public var spaces: [Space]
  
  public func createExportPlan(
    for configuration: HypercutExportConfiguration
  ) -> HypercutExportPlan {
    let keptPhrases = phrases
      .enumerated()
      .filter { (_, phrase) in
        phrase.priority > Int(CGFloat(phrases.count) * configuration.phraseSpeed)
      }
      .map { (i, _) in i }
    
    var tracktimebuilder: [TrackTime] = []
    tracktimebuilder.reserveCapacity(keptPhrases.count * 2 + 1)
    
    for i in keptPhrases {
      let phrase = phrases[i]
      let phraseDuration = (phrase.end - phrase.start) / configuration.playbackSpeed
      let phraseTrack = TrackTime(
        start: phrase.start, 
        end: phrase.end, 
        duration: phraseDuration)
      tracktimebuilder.append(phraseTrack)
      
      if keptPhrases.contains(i - 1) {
        let space = spaces[i]
        let spaceDuration = (space.end - space.start)
          / configuration.playbackSpeed
          * (1 - configuration.pauseSpeed)
        let spaceTrack = TrackTime(
          start: space.start, 
          end: space.end, 
          duration: spaceDuration)
        tracktimebuilder.append(spaceTrack)
      }
    }
    
    return HypercutExportPlan(timecodes: tracktimebuilder)
  }
  
}

public struct HypercutExportPlan {
  var timecodes: [TrackTime]
  
  var runtime: Double {
    timecodes.reduce(0.0) { resultBuilder, trackTime in
      return resultBuilder + trackTime.duration
    }
  }
}
