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
    DispatchQueue.main.async {
      do {
        let asset = try audioAsset()
        asset.writeAudio(to: url, success: success, failure: failure)
      } catch {
        failure(error)
      }
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
      failure(MediaEncoderError.failExport)
      return
    }
    
    exportSession.outputFileType = .m4a
    exportSession.outputURL = url
    
    exportSession.exportAsynchronously {
      switch exportSession.status {
      case .completed:
        success()
      case .unknown, .waiting, .exporting, .failed, .cancelled:
        failure(MediaEncoderError.fileAlreadyExists)
      @unknown default:
        failure(MediaEncoderError.unknown)
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
