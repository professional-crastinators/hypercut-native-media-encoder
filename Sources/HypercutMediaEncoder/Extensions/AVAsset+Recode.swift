////
////  AVAsset+Recode.swift
////  
////
////  Created by Michael Verges on 10/23/21.
////
//
//import AVFoundation
//import HypercutFoundation
//
//struct TimecodeInterval {
//  var start: Double
//  var end: Double
//}
//
//extension AVAsset {
//  // Provide a URL for where you wish to write
//  // the audio file if successful
//  func writeCutTrack(
//    to url: URL,
//    timecodes: [TimecodeInterval],
//    success: @escaping () -> (),
//    failure: @escaping (Error) -> ()
//  ) {
//    do {
//      let asset = try cutAsset()
//      asset.writeCut(to: url, success: success, failure: failure)
//    } catch {
//      failure(error)
//    }
//  }
//  
//  private func writeCut(
//    to url: URL,
//    success: @escaping () -> (),
//    failure: @escaping (Error) -> ()
//  ) {
//    // Create an export session that will output an
//    // audio track (M4A file)
//    guard let exportSession = AVAssetExportSession(
//      asset: self,
//      presetName: AVAssetExportPresetPassthrough
//    ) else {
//      // This is just a generic error
//      let error = NSError(
//        domain: "domain",
//        code: 0,
//        userInfo: nil)
//      failure(error)
//      
//      return
//    }
//    
//    exportSession.outputURL = url
//    
//    exportSession.exportAsynchronously {
//      switch exportSession.status {
//      case .completed:
//        success()
//      case .unknown, .waiting, .exporting, .failed, .cancelled:
//        let error = NSError(domain: "domain", code: 0, userInfo: nil)
//        failure(error)
//      @unknown default:
//        let error = NSError(domain: "domain", code: 0, userInfo: nil)
//        failure(error)
//      }
//    }
//  }
//  
//  private func cutAsset(timecodes: [TimecodeInterval]) throws -> AVAsset {
//    
//    
//    
//    let composition = AVMutableComposition()
//    let allTracks = tracks
//    
//    let trimPoints = timecodes.map { interval in
//      (CMTime.init(seconds: interval.start, preferredTimescale: 1),
//       CMTime.init(seconds: interval.end, preferredTimescale: 1))
//    }
//    
//    for track in allTracks {
//      let compositionTrack = composition.addMutableTrack(
//        withMediaType: track.mediaType,
//        preferredTrackID: track.trackID)
//      
//      compositionTrack?.preferredTransform = compositionTrack.preferredTransform
//      
//      var accumulatedTime = CMTime.zero
//      for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
//        let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
//        let timeRangeForCurrentSlice = CMTimeRangeMake(start: startTimeForCurrentSlice, duration: durationOfCurrentSlice)
//        do {
//          try videoCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
//          try audioCompTrack.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
//        }
//        catch {
//          let error = NSError(domain: "org.linuxguy.VideoLab", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't insert time ranges: \(error)"])
//          completion?(error)
//          return
//        }
//        
//        accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
//      }
//      
//
//    }
//    
//    return composition
//  }
//}
