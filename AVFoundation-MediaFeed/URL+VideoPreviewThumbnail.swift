//
//  URL+VideoPreviewThumbnail.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation

extension URL {
  
  public func videoPreviewThumnail() -> UIImage? {
    // create an  AVAsset instance
    // e.g. let image = mediaObject.videoURL.videoPreviewThumnail()
    let asset = AVAsset(url: self) // self is the URL instance
    
    // The AVAssetImageGenerator is an AVFoundation class that converts a given media url to an image
    let assetGenerator = AVAssetImageGenerator(asset: asset)
    
    // we wan to maintain the aspect ratio of the video
    assetGenerator.appliesPreferredTrackTransform = true
    
    // create a time stamp of needed location in the video
    // we will use a CMTime to generate the given time stamp
    // CMTime is part of Core Media
    let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
    // retrive the first second of the video
    
    var image: UIImage?
    
    do {
      let cgImage = try assetGenerator.copyCGImage(at: timestamp, actualTime: nil)
      image = UIImage(cgImage: cgImage)
      
      // UIView
      // Layer
      
      // lower level API don't know about UIKit, AVKit \
      // change the color of a UIView border
      // e.g someView.layer.borderColor = UIColor.green.cgColor
    } catch {
      print("failed to generate image: \(error)")
    }
    return image
  }
}
