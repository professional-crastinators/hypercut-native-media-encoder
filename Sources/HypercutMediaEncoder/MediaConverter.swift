//
//  MediaConverter.swift
//  
//
//  Created by Michael Verges on 10/22/21.
//

import AVFoundation

struct MediaConverter {
  
  let filepath: URL
  
  init(filepath: URL) {
    self.filepath = filepath
  }
  
  var newURL = FileManager.default
    .urls(for: .documentDirectory, in: .userDomainMask)[0]
    .appendingPathComponent("hypercut-audio.m4a")
  
  func getAudio(_ completion: @escaping (Data) -> ()) {
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
