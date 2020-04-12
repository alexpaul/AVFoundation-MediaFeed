//
//  MediaCell.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

protocol MediaCellDelegate: AnyObject {
  func didLongPress(_ mediaCell: MediaCell, mediaObject: CDMediaObject)
}

class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  @IBOutlet weak var playButtonIcon: UIImageView!
  
  private var mediaObject: CDMediaObject!
  
  weak var delegate: MediaCellDelegate?
  
  private lazy var longPressGesture: UILongPressGestureRecognizer = {
    let gesture = UILongPressGestureRecognizer()
    gesture.addTarget(self, action: #selector(handleLongPress(_:)))
    return gesture
  }()
  
  private var longPressStarted = false
  
  override func layoutSubviews() {
    super.layoutSubviews()
    addGestureRecognizer(longPressGesture)
    backgroundColor = .systemGroupedBackground
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    //playButtonIcon.isHidden = false
  }
  
  @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
      if longPressStarted { return }
      longPressStarted = true
      delegate?.didLongPress(self, mediaObject: mediaObject)
      print("long press")
    default:
      longPressStarted = false
    }
  }
  
  private func setImage(for mediaObject: CDMediaObject) {
    if let imageData = mediaObject.imageData {
      mediaImageView.image = UIImage(data: imageData)
    }
  }
  
  public func configureCell(for mediaObject: CDMediaObject) {
    self.mediaObject = mediaObject
    setImage(for: mediaObject)
    if let _ = mediaObject.videoData { // is video
      playButtonIcon.isHidden = false
    } else {
      playButtonIcon.isHidden = true
    }
  }
}
