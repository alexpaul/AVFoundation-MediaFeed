//
//  ViewController.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation // video playback is done on a (CALayer) - all views are backed by a CALayer e.g if we want to make a view rounded we can only do this using the CALayer of that view, e.g someView.layer.cornerRadius = 10
import AVKit // video playback is done using the AVPlayerViewConroller

class MediaFeedViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var videoButton: UIBarButtonItem!
  @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
  
  private lazy var imagePickerController: UIImagePickerController = {
    let mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
    let pickerController = UIImagePickerController()
    pickerController.mediaTypes = mediaTypes ?? ["kUTTypeImage"]
    pickerController.delegate = self
    return pickerController
  }()
  
  private var mediaObjects = [MediaObject]() {
    didSet { // property observer
      collectionView.reloadData()
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCollectionView()
    
    if !UIImagePickerController.isSourceTypeAvailable(.camera) {
      videoButton.isEnabled = false
    }
  }
  
  private func configureCollectionView() {
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
    
  }
  
  
  @IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .photoLibrary
    present(imagePickerController, animated: true)
  }
}

// MARK: UICollection View DataSource methods

extension MediaFeedViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mediaObjects.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
      fatalError("could not dequeue a MediaCell")
    }
    let mediaObject = mediaObjects[indexPath.row]
    cell.configureCell(for: mediaObject)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
      fatalError("could not dequeue a HeaderView")
    }
    return headerView // is of the UICollectionReusableView
  }
}

// MARK: UICollection View Delegate Methods
extension MediaFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let mediaOjbect = mediaObjects[indexPath.row]
    guard let videoURL = mediaOjbect.videoURL else {
      return
    }
    let playerViewController = AVPlayerViewController()
    let player = AVPlayer(url: videoURL)
    playerViewController.player = player
    present(playerViewController, animated: true) {
      // play video automatically
      player.play()
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxSize: CGSize = UIScreen.main.bounds.size // max width and height of the current device
    let itemWidth: CGFloat = maxSize.width
    let itemHeight: CGFloat = maxSize.height * 0.40 // 40% of the height of the device
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    
    return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.40)
  }

}

extension MediaFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    // info dictionary keys
    // InfoKey.originalImage - UIImage
    // InfoKey.mediaType - String
    // Infokey.mediaURL - URL
    
    guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
      return
    }
    
    switch mediaType { // "public.movie" , "public.image"
    case "public.image":
      if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
        let imageData = originalImage.jpegData(compressionQuality: 1.0){
        let mediaObject = MediaObject(imageData: imageData, videoURL: nil, caption: nil)
        mediaObjects.append(mediaObject) // 0 => 1
      }
    case "public.movie":
      if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
        print("mediaURL: \(mediaURL)")
        let mediaObject = MediaObject(imageData: nil, videoURL: mediaURL, caption: nil)
        mediaObjects.append(mediaObject)
      }
    default:
      print("unsupported media type")
    }
    
    picker.dismiss(animated: true)
  }
}
