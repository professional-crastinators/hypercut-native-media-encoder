//
//  AVAsset+Recode.swift
//  
//
//  Created by Michael Verges on 10/23/21.
//

import AVFoundation
import HypercutFoundation

extension AVAsset {
  // Provide a URL for where you wish to write
  // the audio file if successful
  func writeCutTrack(
    to url: URL,
    timecodes: [TimecodeInterval],
    success: @escaping () -> (),
    failure: @escaping (Error) -> ()
  ) {
    do {
      let asset = try cutAsset(timecodes: timecodes)
      asset.writeCut(to: url, success: success, failure: failure)
    } catch {
      failure(error)
    }
  }
  
  private func writeCut(
    to url: URL,
    success: @escaping () -> (),
    failure: @escaping (Error) -> ()
  ) {
    
    guard let exportSession = AVAssetExportSession(
      asset: self,
      presetName: AVAssetExportPresetHighestQuality
    ) else {
      failure(MediaEncoderError.failExport)
      return
    }
    
    exportSession.outputURL = url
    exportSession.outputFileType = .mov
    
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
  
  private func cutAsset(timecodes: [TimecodeInterval]) throws -> AVAsset {
    let composition = AVMutableComposition()
    let allTracks = tracks
    
    let trimPoints = timecodes.map { interval in
      (CMTime.init(seconds: interval.start, preferredTimescale: 1),
       CMTime.init(seconds: interval.end, preferredTimescale: 1))
    }
    
    for track in allTracks {
      let compositionTrack = composition.addMutableTrack(
        withMediaType: track.mediaType,
        preferredTrackID: track.trackID)
      
      compositionTrack?.preferredTransform = track.preferredTransform
      
      var accumulatedTime = CMTime.zero
      for (start, end) in trimPoints {
        let durationOfCurrentSlice = CMTimeSubtract(end, start)
        let timeRangeForCurrentSlice = CMTimeRangeMake(start: start, duration: durationOfCurrentSlice)
        do {
          try compositionTrack?.insertTimeRange(timeRangeForCurrentSlice, of: track, at: accumulatedTime)
        } catch {
          print(error)
        }
        accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
      }
      

    }
    
    return composition
  }
}
