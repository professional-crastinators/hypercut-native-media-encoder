//
//  MediaRecoder.swift
//  
//
//  Created by Michael Verges on 10/23/21.
//

import AVFoundation
import HypercutFoundation

public struct MediaRecoder {
  
  let filepath: URL
  
  public init(filepath: URL) {
    self.filepath = filepath
  }
  
  var newURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("hypercut-\(UUID().uuidString).mov")
  
  public func getCut(
    timecodes: HypercutExportPlan, 
    progress: @escaping (Float) -> (), 
    completion: @escaping (URL) -> ()) {
    let asset = AVAsset(url: filepath)
    
    asset.writeCutTrack(to: newURL, timecodes: timecodes) { 
      completion(newURL)
    } progress: { value in
      progress(value)
    } failure: { error in
      fatalError(error.localizedDescription)
    }

  }
}
