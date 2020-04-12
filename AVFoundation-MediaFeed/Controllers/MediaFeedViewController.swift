//
//  ViewController.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

enum MediaSelected {
  case image, video
}

class MediaFeedViewController: UIViewController {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  @IBOutlet weak var videoButton: UIBarButtonItem!
  @IBOutlet weak var photoLibraryButton: UIBarButtonItem!
  
  private var mediaObjects = [CDMediaObject]() {
    didSet {
      collectionView.reloadData()
    }
  }
  
  private lazy var imagePickerController: UIImagePickerController = {
    let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) ?? ["kUTTypeImage"]
    let imagePicker = UIImagePickerController()
    imagePicker.mediaTypes = mediaTypes
    imagePicker.delegate = self
    return imagePicker
  }()
  
  private var mediaSelected = MediaSelected.image
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    // disable the video is not supported on the current device, e.g the simulator
    if !(UIImagePickerController.isSourceTypeAvailable(.camera)) {
      videoButton.isEnabled = false
    }
    
    fetchMediaObjects()
  }
  
  private func fetchMediaObjects() {
    mediaObjects = CoreDataManager.shared.fetchMediaObjects()
  }
  
  func playRandomVideo(in view: UIView) {
    let videoDataObjects  = mediaObjects.compactMap { $0.videoData }
    if let videoData = videoDataObjects.randomElement(),
      let videoURL = videoData.videoURLFromData() {
      let player = AVPlayer(url: videoURL)
      let playerLayer = AVPlayerLayer(player: player)
      playerLayer.frame = view.bounds
      playerLayer.videoGravity = .resizeAspect
      
      // remove all layers before adding a new one
      view.layer.sublayers?.removeAll()
      
      view.layer.addSublayer(playerLayer)
      
      player.play()
    }
  }
  
  @IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .camera
    present(imagePickerController, animated: true)
  }
  
  
  @IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
    imagePickerController.sourceType = .photoLibrary
    present(imagePickerController, animated: true)
  }
}

extension MediaFeedViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return mediaObjects.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
      fatalError("could not dequeue a MediaCell")
    }
    let mediaObjet = mediaObjects[indexPath.row]
    cell.configureCell(for: mediaObjet)
    cell.delegate = self
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
      fatalError("could not cast to HeaderView")
    }
    
    playRandomVideo(in: headerView)
    
    return headerView
  }
}

extension MediaFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let mediaObject = mediaObjects[indexPath.row]
    if let videoData = mediaObject.videoData,
      let videoURL = videoData.videoURLFromData() {
      let player = AVPlayer(url: videoURL)
      let playerViewController = AVPlayerViewController()
      playerViewController.player = player
      present(playerViewController, animated: true) {
        player.play()
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxSize: CGSize = UIScreen.main.bounds.size
    let itemWidth: CGFloat = maxSize.width * 0.90
    let itemHeight: CGFloat = itemWidth
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.40)
  }
}


extension MediaFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let mediaTypes = info[UIImagePickerController.InfoKey.mediaType] as? String else {
      return
    }
    switch mediaTypes {
    case "public.image":
      print("image selected")
      
      mediaSelected = .image
      
      if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
        let imageData = originalImage.jpegData(compressionQuality: 1.0) {
        
        
        //let mediaObject = MediaObject(imageData: imageData, mediaURL: nil, caption: nil)
        let mediaObject = CoreDataManager.shared.createMediaObject(imageData: imageData)
        mediaObjects.append(mediaObject)
        
        
      }
      
    case "public.movie":
      print("video selected")
      
      mediaSelected = .video
      
      
      if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
        if let image = mediaURL.videoPreviewImage(),
          let imageData = image.jpegData(compressionQuality: 1.0) {
          
          
          //let mediaObject = MediaObject(imageData: imageData, mediaURL: mediaURL, caption: nil)
          let mediaObject = CoreDataManager.shared.createMediaObject(mediaURL: mediaURL, imageData: imageData)
          mediaObjects.append(mediaObject)
          
          
        }
      }
      
    default:
      
      print("unsupported media type")
    }
    picker.dismiss(animated: true)
  }
}


extension URL {
  public func videoPreviewImage() -> UIImage? {
    let asset = AVAsset(url: self)
    let assetGenerator = AVAssetImageGenerator(asset: asset)
    assetGenerator.appliesPreferredTrackTransform = true
    let timestamp = CMTime(seconds: 1, preferredTimescale: 60)
    var image: UIImage?
    do {
      let cgImage = try assetGenerator.copyCGImage(at: timestamp, actualTime: nil)
      image = UIImage(cgImage: cgImage)
    } catch {
      print("failed to generated image with error: \(error)")
    }
    return image
  }
}


extension MediaFeedViewController: MediaCellDelegate {
  func didLongPress(_ mediaCell: MediaCell, mediaObject: CDMediaObject) {
    let alertController = UIAlertController(title: "Delete Media", message: "Are you sure that you want to delete this item. Action cannot be undone.", preferredStyle: .actionSheet)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [unowned self] (alertAction) in
      self.deleteMediaObject(mediaObject)
    }
    alertController.addAction(cancelAction)
    alertController.addAction(deleteAction)
    present(alertController, animated: true)
  }
  
  private func deleteMediaObject(_ mediaObject: CDMediaObject) {
    CoreDataManager.shared.deleteMediaObject(mediaObject)
    let index = mediaObjects.firstIndex(of: mediaObject)
    if let index = index {
      mediaObjects.remove(at: index)
    }
  }
}

extension Data {
  // convert Data to a URL
  public func videoURLFromData() -> URL? {
    let tmpFileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("video").appendingPathExtension("mp4")
    do {
      try self.write(to: tmpFileURL, options: [.atomic])
      return tmpFileURL
    } catch {
      print("failed to write to file url with error: \(error)")
    }
    return nil
  }
}

