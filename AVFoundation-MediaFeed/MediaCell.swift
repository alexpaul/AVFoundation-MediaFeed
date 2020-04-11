//
//  MediaCell.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  
  public func configureCell(for mediaObject: MediaObject, mediaSelected: MediaSelected) {
    if mediaSelected == .image {
      if let imageData = mediaObject.imageData {
        mediaImageView.image = UIImage(data: imageData)
      }
    } else {
      //
    }
  }
}
