//
//  Data+ConvertToURL.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/15/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

extension Data {
  
  // use case example:
  // let url = mediaObject.videoData.convertToURL()
  // let url = mediaObject.self.convertToURL()
  public func convertToURL() -> URL? {
    
    // create a temporary URL
    // NSTemporaryDirectory() - stores temporary files, those files get deleted as needed by the operating system
    // documents directory is for permanent storage
    // caches directory is temporary storage
    
    // in Core Data the video is saved as Data
    // when playing back the video we need to have a URL pointing to the video location on disk
    // AVPlayer need a URL pointing to a location on disk
    let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
    do {
      try self.write(to: tempURL, options: [.atomic])
      return tempURL
    } catch {
      print("failed to write (save) video data to temporary file with error: \(error)")
    }
    return nil
  }
}
