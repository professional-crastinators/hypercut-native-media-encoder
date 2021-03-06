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
    timecodes: HypercutExportPlan,
    success: @escaping () -> (),
    progress: @escaping (Float) -> (),
    failure: @escaping (Error) -> ()
  ) {
    DispatchQueue.main.async {
      do {
        let asset = try self.speedAsset(timecodes: timecodes, progress: progress)
        asset.writeCut(to: url, highQuality: timecodes.highQuality, success: success, failure: failure)
      } catch {
        failure(error)
      }
    }
  }
  
  private func writeCut(
    to url: URL,
    highQuality: Bool,
    success: @escaping () -> (),
    failure: @escaping (Error) -> ()
  ) {
    
    guard let exportSession = AVAssetExportSession(
      asset: self,
      presetName: highQuality
        ? AVAssetExportPresetHighestQuality
        : AVAssetExportPresetMediumQuality
    ) else {
      failure(MediaEncoderError.failExport)
      return
    }
    
    exportSession.outputURL = url
    exportSession.outputFileType = .mov
    
    if let sourceVideoTrack = tracks(withMediaType: .video).first {
      let mainInstruction = AVMutableVideoCompositionInstruction()
      mainInstruction.timeRange = sourceVideoTrack.timeRange
      let mutableComposition = AVMutableVideoComposition()
      mutableComposition.renderSize = sourceVideoTrack.naturalSize
      mutableComposition.frameDuration = sourceVideoTrack.minFrameDuration
      
      let scale : CGAffineTransform = CGAffineTransform(scaleX: 1, y:1)
      for videoTrack in tracks(withMediaType: .video) {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        instruction.setTransform(
          sourceVideoTrack.preferredTransform.concatenating(scale), at: .zero)
        mainInstruction.layerInstructions.append(instruction)
      }
      
      mutableComposition.instructions = (exportSession.videoComposition?.instructions ?? []) + [mainInstruction]
      exportSession.videoComposition = mutableComposition
    }
    
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
  
  private func speedAsset(
    timecodes: HypercutExportPlan,
    progress: @escaping (Float) -> ()
  ) throws -> AVAsset {
    let composition = AVMutableComposition()
    let allTracks = tracks
    
    var completed: Float = 0
    let increment = 1.0 / Float(timecodes.timecodes.count * allTracks.count)
    let callback = {
      completed += increment
      progress(completed)
    }
    
    for track in allTracks {
      let compositionTrack = composition.addMutableTrack(
        withMediaType: track.mediaType,
        preferredTrackID: track.trackID)
      
      compositionTrack?.preferredTransform = track.preferredTransform
      
      var accumulatedTime = CMTime.zero
      for trackTime in timecodes.timecodes {
        let durationOfCurrentSlice = CMTimeSubtract(
          trackTime.endTime, trackTime.startTime)
        let timeRangeForCurrentSlice = CMTimeRangeMake(
          start: trackTime.startTime, duration: durationOfCurrentSlice)
        do {
          try compositionTrack?.insertTimeRange(
            timeRangeForCurrentSlice, of: track, at: accumulatedTime)
          if trackTime.durationTime != durationOfCurrentSlice {
            let timeRangeRecode = CMTimeRangeMake(
              start: accumulatedTime, duration: durationOfCurrentSlice)
            compositionTrack?.scaleTimeRange(
              timeRangeRecode, toDuration: trackTime.durationTime)
          }
        } catch {
          print(error)
        }
        accumulatedTime = CMTimeAdd(accumulatedTime, trackTime.durationTime)
        
        callback()
      }
    }
    
    progress(1.0)
    
    return composition
  }
}
