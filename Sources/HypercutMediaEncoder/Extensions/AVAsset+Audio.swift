//
//  AVAsset+Audio.swift
//  
//
//  Created by Michael Verges on 10/22/21.
//

import AVFoundation

extension AVAsset {
  // Provide a URL for where you wish to write
  // the audio file if successful
  func writeAudioTrack(
    to url: URL,
    success: @escaping () -> (),
    failure: @escaping (Error) -> ()
  ) {
    do {
      let asset = try audioAsset()
      asset.writeAudio(to: url, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  private func writeAudio(
    to url: URL,
    success: @escaping () -> (),
    failure: @escaping (Error) -> ()
  ) {
    // Create an export session that will output an
    // audio track (M4A file)
    guard let exportSession = AVAssetExportSession(
      asset: self,
      presetName: AVAssetExportPresetAppleM4A
    ) else {
      // This is just a generic error
      let error = NSError(
        domain: "domain",
        code: 0,
        userInfo: nil)
      failure(error)
      
      return
    }
    
    exportSession.outputFileType = .m4a
    exportSession.outputURL = url
    
    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        success()
      case .unknown, .waiting, .exporting, .failed, .cancelled:
        let error = NSError(domain: "domain", code: 0, userInfo: nil)
        failure(error)
      @unknown default:
        let error = NSError(domain: "domain", code: 0, userInfo: nil)
        failure(error)
      }
    }
  }
  
  private func audioAsset() throws -> AVAsset {
    
    let composition = AVMutableComposition()
    let audioTracks = tracks(withMediaType: .audio)
    
    for track in audioTracks {
      let compositionTrack = composition.addMutableTrack(
        withMediaType: .audio,
        preferredTrackID: kCMPersistentTrackID_Invalid)
      do {
        // Add the current audio track at the beginning of
        // the asset for the duration of the source AVAsset
        try compositionTrack?.insertTimeRange(
          track.timeRange,
          of: track,
          at: track.timeRange.start)
      } catch {
        throw error
      }
    }
    
    return composition
  }
}
