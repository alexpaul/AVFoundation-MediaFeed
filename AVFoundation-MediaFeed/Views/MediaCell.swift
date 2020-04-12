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
  
  private func setImage(for mediaObject: CDMediaObject) {
    if let imageData = mediaObject.imageData {
      mediaImageView.image = UIImage(data: imageData)
    }
  }
  
  public func configureCell(for mediaObject: CDMediaObject, mediaSelected: MediaSelected) {
    setImage(for: mediaObject)
    if mediaSelected == .image {
      //
    } else {
      //
    }
  }
}
