//
//  MediaCell.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//


import UIKit

class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  
  public func configureCell(for mediaObject: MediaObject) {
    if let imageData = mediaObject.imageData {
      // converts a Data object to a UIImage
      mediaImageView.image = UIImage(data: imageData)
    }
        
    // create a video preview thumbnail
    if let videoURL = mediaObject.videoURL {
      let image = videoURL.videoPreviewThumnail() ?? UIImage(systemName: "heart")
      mediaImageView.image = image
    }
  }
}
