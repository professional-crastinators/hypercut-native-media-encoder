//
//  MediaConverter.swift
//  
//
//  Created by Michael Verges on 10/22/21.
//

import AVFoundation

public struct MediaConverter {
  
  let filepath: URL
  
  public init(filepath: URL) {
    self.filepath = filepath
  }
  
  var newURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("hypercut-audio-\(UUID().uuidString).m4a")
  
  public func getAudio(_ completion: @escaping (Data) -> ()) {
    let asset = AVAsset(url: filepath)
    
    asset.writeAudioTrack(to: newURL) {
      do {
        completion(try .init(contentsOf: newURL))
      } catch {
        print(error)
      }
    } failure: { error in
      print(error)
    }
  }
}
