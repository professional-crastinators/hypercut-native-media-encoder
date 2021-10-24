//
//  HypercutExportSession.swift
//  
//
//  Created by Michael Verges on 10/23/21.
//

import Foundation
import HypercutFoundation

public struct HypercutExportConfiguration {
  
  public init(
    pauseSpeed: CGFloat,
    phraseSpeed: CGFloat,
    playbackSpeed: CGFloat
  ) {
    self.pauseSpeed = pauseSpeed
    self.phraseSpeed = phraseSpeed
    self.playbackSpeed = playbackSpeed * 3 + 1
  }
  
  public var pauseSpeed: CGFloat
  public var phraseSpeed: CGFloat
  public var playbackSpeed: CGFloat
}

public struct HypercutExportSession {
  
  public init(
    phrases: [Phrase],
    spaces: [Space]
  ) {
    self.phrases = phrases
    self.spaces = spaces
  }
  
  public var phrases: [Phrase]
  public var spaces: [Space]
  
  public func createExportPlan(
    for configuration: HypercutExportConfiguration
  ) -> HypercutExportPlan {
    let keptPhrases = phrases
      .enumerated()
      .filter { (_, phrase) in
        phrase.priority > max(
          Int(CGFloat(phrases.count) * configuration.phraseSpeed), 
          phrases.count - 4)
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
        * (1 - max(configuration.pauseSpeed, 0.01))
        let spaceTrack = TrackTime(
          start: space.start, 
          end: space.end, 
          duration: spaceDuration)
        tracktimebuilder.append(spaceTrack)
      }
    }
    
    return HypercutExportPlan(timecodes: tracktimebuilder, runtime: {
      tracktimebuilder.reduce(0.0) { resultBuilder, trackTime in
        return resultBuilder + trackTime.duration
      }
    }())
  }
  
}

public struct HypercutExportPlan {
  var timecodes: [TrackTime]
  public var runtime: Double
}
