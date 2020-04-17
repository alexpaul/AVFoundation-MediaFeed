# AVFoundation-MediaFeed


Introduction to AVFoundation and AVKit frameworks.

In this lesson we will be building an app that captures video and plays back the content in a **CALayer** or the built-in **AVPlayerViewController**.

![media-feed-app](https://github.com/joinpursuit/Pursuit-Core-iOS-AVFoundation-AVKit/raw/master/media-feed-app.png)

## Objectives 

1. Capture video using UIImagePickerController 
1. Play video using AVPlayerViewController 
1. Generate video preview using AVAssetImageGenerator 
1. Play video using a CALayer 
1. Persist video (here we can use persistent APIs we have seen before: FileManager and documents directory or more recently Core Data, video files can also be stored of Firebase Storage) 

## 1. AVFoundation 

> Apple documentation: The AVFoundation framework combines four major technology areas that together encompass a wide range of tasks for capturing, processing, synthesizing, controlling, importing and exporting audiovisual media on Apple platforms.

## 2. Let's begin 

Create a new Xcode project. Our app will be called **AVFoundation-MediaFeed**. 

## 3. Overview of user interface for the app

The app will be embedded in a UINavigationController. In the navigation bar we will have two UIBarButtonItems, a button for selecting the device's video capture and the second button will retrieve content from the user's photo library. 

We will use a collection view to display the user generated content (images and video). The collection view will have a supplementary header view that displays a random video. The cells of the collection view will either display an image of a still image selected or a video preview thumbnail if a video was captured. 

## 4. ViewController 

Refactor the default ViewController class name and call it **MediaFeedViewController**. Go to the storyboard and embedd the one scene into a UINavigationController. 

Add two UIBarButtonItem 's to the navigation bar. Select **photo.fill** and **video.fill** respectively from the attributes inspector. Those SFSymbols (photo.fill and video.fill) are only supported in iOS 13 and above.

Set the navigation title to **Media Feed** 

Drag in a collection view to the view controller scene and set its constraints to 0 at all edges (top (safe area), leading, bottom (safe area) and trailing) 

Set the cell's ```reuse identifier``` to **mediaCell** 

As per the cell in the collection view set the size to 340 X 340. We will further configure the exact size in the view controller's ```sizeForItem(:_)``` method. 

Drag in an image view to the cell, set the constraints to 0 all around. Feel free to set a default image on the image view.

The scrolling direction of our collection view will remain **vertical**. 

We will be using a **section header** on our collection view so set the attribute to the left of the **Accessories** option in the attributes inspector on the collection view. Select the newly added reusable view and give it a reuse identifier of **headerView** 

At this point all our attributes are set, let's now connect this scene's elements to the **MediaFeedViewController** Option-click on the MediaFeedViewController to bring up the assistant editor. 

Control-drag from the collection view to the MediaFeedViewController and make the outlet connection, name it ```collectionView```. Control-drag the two UIBarButtonItem 's and name the outlets ```videoButton``` and ```photoLibraryButton``` respectively. Control-drag from the two UIBarButtonItem 's to create IBAction's (videoButtonPressed() and photoLibraryButtonPressed())

Set the collection view's dataSource and delegate in viewDidLoad(). Write an extension to conform to the dataSource and delegate outside the class. 

#### Collection View extensions for the dataSource and delegate 

```swift 
extension MediaFeedViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 20
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath)
    return cell
  }
}

extension MediaFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let maxSize: CGSize = UIScreen.main.bounds.size
    let itemWidth: CGFloat = maxSize.width * 0.80
    let itemHeight: CGFloat = itemWidth
    return CGSize(width: itemWidth, height: itemHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
}
```

In this app we do not want automatic cell resizing since we are returning a specific size so we will need to turn automatic resizing to none. Navigate to the size inspector for the collection view and toggle **automatic** resizing to **none** for the ```Estimate Size``` option.


## 5. Supplementary view 

We will be adding a custom header view to our collection view. Create a new file. This file will be a subclass of **UICollectionReusableView** , name the file **HeaderView** 

> UICollectionReusableView - Reusable views are so named because the collection view places them on a reuse queue rather than deleting them when they are scrolled out of the visible bounds. Such a view can then be retrieved and repurposed for a different set of content.

```swift 
class HeaderView: UICollectionReusableView {
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = .systemYellow
  }
}
```

Navigate to the storyboard, select the section header on the collection view and change the class to **HeaderView** in the identity inspector. 

Implement viewForSupplementaryElementKind() dataSource method and return the header view 

```swift 
func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
  guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as? HeaderView else {
    fatalError("could not cast to HeaderView")
  }
  return headerView
}
```

Implement the referenceSizeForHeaderInSection() delegate method to return a size for the header view 

```swift 
func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
  return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height * 0.40)
}
```

#### If you need to register a supplementary view programmactically 

```swift 
collectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView")
```

## 6. The model for our app

Creete a new file. It will be a Swift file and name it **MediaObjet** 

```swift 
struct MediaObject {
  let imageData: Data?
  let videoURL: String?
  let caption: String?
  let createdDate = Date()
  let id = UUID().uuidString
}
```

## 7. Data for MediaFeedViewController 

Add a private variable array to the view contorller called **mediaObjects**

```swift 
private var mediaObjects = [MediaObject]() {
  didSet {
    collectionView.reloadData()
  }
}
```

Update the cellForRow() to now return ```return mediaObjects.count```


## 8. Configuring UIImagePickerController to capture images and video 

We have seen UIImagePickerController before but today we will take its configuration a bit further and add video capture capabilites. 

#### Add a UIImagePickerController lazy property to the MediaFeedViewController

```swift 
private lazy var imagePickerController: UIImagePickerController = {
  let mediaTypes = UIImagePickerController.availableMediaTypes(for: .savedPhotosAlbum) ?? ["kUTTypeImage"]
  let imagePicker = UIImagePickerController()
  imagePicker.mediaTypes = mediaTypes
  imagePicker.delegate = self
  return imagePicker
}()
```

Conform to the UIImagePickerControllerDelegate

```swift 
extension MediaFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
  }
}
```

#### Disable the video button if not supported on the current running device 

```swift 
// disable the video is not supported on the current device, e.g the simulator
if !(UIImagePickerController.isSourceTypeAvailable(.camera)) {
  videoButton.isEnabled = false
}
```



#### Access the user's saved photos album if the photoLibrary button was selected

```swift 
@IBAction func photoLibraryButtonPressed(_ sender: UIBarButtonItem) {
  imagePickerController.sourceType = .photoLibrary
  present(imagePickerController, animated: true)
}
```

#### Updated didFinishPickingMediaWithInfo methood 

Supported media types are ```public.video``` and ```public.image``` 

```swift 
extension MediaFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    guard let mediaTypes = info[UIImagePickerController.InfoKey.mediaType] as? String else {
      return
    }
    switch mediaTypes {
    case "public.image":
      print("image selected")
      
      if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage,
        let imageData = originalImage.jpegData(compressionQuality: 1.0) {
        let mediaObject = MediaObject(imageData: imageData, videoURL: nil, caption: nil)
        mediaObjects.append(mediaObject)
      }
      
    case "public.movie":
      print("video selected")
    default:
      print("unsupported media type")
    }
    picker.dismiss(animated: true)
  }
}
```

#### Keep track of the selected media the user choose in the MediaFeedViewController 

Here we will use an enum to keep track of the selected media state

```swift
enum MediaSelected {
  case image, video
}

class MediaFeedViewController {}
```

```swift 
private var mediaSelected = MediaSelected.image
```


## 9. Custom cell for collection view 

```swift 
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
```

#### Updated cellForRow() 

```swift 
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
    fatalError("could not dequeue a MediaCell")
  }
  let mediaObjet = mediaObjects[indexPath.row]
  cell.configureCell(for: mediaObjet, mediaSelected: mediaSelected)
  return cell
}
```

## 10. Capturing video using UIImagePickerController 

Update the videButtonPressed() method to present the UIImagePickerController. 

```swift 
@IBAction func videoButtonPressed(_ sender: UIBarButtonItem) {
  imagePickerController.sourceType = .camera
  present(imagePickerController, animated: true)
}
```

We need to set the following **Info.plist** keys: 
1. NSCameraUsageDescription - request the user's permission to access the camera. Also a String explaning why you need access is required. ```Please allow MediaFeed access to your camera to add video content to feed.```
2. NSMicrophoneUsageDescription - this key is needed when switching from Photo to Video capture. The user needs to allow access to the microphone while video is being recorded. ```Please allow MediaFeed access to your microphone during video recordings.```


## 11. Making a video preview (Welcome to AVFoundation)

When a video is added by the user we want to show a video thumbnail preview of this captured video. We will be using the **AVAssetImageGenerator** class for this. AVAssetImageGenerator is part of the **AVFoundation framework** so we will need to import AVFoundation into our MediaFeedViewController class. 

Implement the method needed to generate this image preview via an extension on the URL class. We are doing so because we will be getting back a URL of the captured video. This URL contains the video content. We will be passing this URL to our method generating the URL and getting back a UIImage. This image will be added to the **MediaCell** 

```swift 
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
```

#### AVAsset 

> Apple documentation: An AVAsset defines the collective properties of the tracks that comprise the asset. You create an AVAsset by initializing it with a local or remote URL pointing to a media resource, as shown in the following example:

```swift 
let url: URL = // local or remote Asset URL 
let asset = AVAsset(url: url)
```

#### AVAssetImageGenerator 

> Apple docmentation: An object that provides thumbnail or preview images of assets independently of playback.


#### CMTime 

CMTime is a Core Media struct for representing a timestamp or duration. 

#### CGImage 

CGImage is a class from Core Graphics and represents an image. 

> Apple documentation: a bitmap image or image mask


#### appliesPreferredTrackTransform() 

> Apple documentation: Specifies whether to apply the track matrix, or matrices. when extracting an image from the asset.


#### Updated didFinishPickingMediaWithInfo() 

```swift 
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
      let mediaObject = MediaObject(imageData: imageData, mediaURL: nil, caption: nil)
      mediaObjects.append(mediaObject)
    }

  case "public.movie":
    print("video selected")

    mediaSelected = .video


    if let mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
      if let image = mediaURL.videoPreviewImage(),
        let imageData = image.jpegData(compressionQuality: 1.0) {
        let mediaObject = MediaObject(imageData: imageData, mediaURL: mediaURL, caption: nil)
        mediaObjects.append(mediaObject)
      }
    }


  default:
    print("unsupported media type")
  }
  picker.dismiss(animated: true)
}
```

#### Updated MediaCell 

```swift 
class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  
  private func setImage(for mediaObject: MediaObject) {
    if let imageData = mediaObject.imageData {
      mediaImageView.image = UIImage(data: imageData)
    }
  }
  
  public func configureCell(for mediaObject: MediaObject, mediaSelected: MediaSelected) {
    setImage(for: mediaObject)
    if mediaSelected == .image {
      //
    } else {
      //
    }
  }
}
```

## 12. Playing a video using AVPlayerViewController

AVPlayerViewController is part of AVKit and not AVFoundation. In order to using the AVPlayerViewController we will have to import AVKit in the MediaFeedViewController. 

We will check to see what media selected state our app is in when the user taps on a media object in the collection view. If the state is **.video** then we will present the AVPlayerViewController and automatically start playing the video. 

Implement **didSelectItemAt()** in the collection view delegate extension 

```swift 
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
```

## 13. Playing a video in a UIView via the UIView's CALayer

As we learnt back earlier in iOS developmenet every UIView is backed by a CALayer. On this CALayer we were able to make our views rounded by setting the cornerRaduis of the layer ```someView.layer.cornerRadius = 8```. In AVFoundation we will be re-visiting CALayer, this time we will be using the CALayer of a view to render playing a video. 

In order to add the video to the view's layer we first create an AVPlayerLayer, also a CALayer object, this object that takes an AVPlayer in its' initializer. 

```swift
let playerLayer = AVPlayerLayer(player: player)
```

We set the AVPlayerLayer's **frame** and **videoGravity**. 

videoGravity: aspect ratio of video 

After configuring the AVPlayerLayer we pass it to the view's layer as a subLayer (we would say adding a subview in regards to UIView). 

```swift
view.layer.addSublayer(playerLayer)
```

Full method implementation 

```swift 
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
```

As we will be randomly playing a video in the collection view's header view add this code to the viewForSupplementaryElementOfKind() method 

```swift 
playRandomVideo(in: headerView)
```

## 14. Persisting user generated media content 

There are many ways in which we can choose to persist (save) user generated content in our app, documents directory, Firebase, iCloud....we will use Core Data. If our app gets implemented beyond MVP in complexity we will ultimately have object relationships, Core Data will be great in that use case. 

#### Adding the Core Data stack to an existing app. 
<details>
  <summary>Add this Core Data stack to the AppDelegate</summary> 
  
```swift 
import CoreData

// MARK: - Core Data stack
lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
    */
    let container = NSPersistentContainer(name: "MediaFeedDataModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

            /*
             Typical reasons for an error here include:
             * The parent directory does not exist, cannot be created, or disallows writing.
             * The persistent store is not accessible, due to permissions or data protection when the device is locked.
             * The device is out of space.
             * The store could not be migrated to the current model version.
             Check the error message to determine what the actual problem was.
             */
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    })
    return container
}()

// MARK: - Core Data Saving support
func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
```

</details>

Create a new file and select Data Model in the file choice template dialog beneath Core Data. Name the file **MediaFeedDataModel** 

Open the MediaFeedDataModel and add an entity named **CDMediaObject**. 

#### Add the following attributes and associated types to the CDMediaObject entity. 

| Attribute | Type | Extra Configurations |
|:------:|:------:|:------:|
| imageData | Binary Data | check **Allows External Storage**, this will save large files outside of Core Data |
| videoData | Binary Data | same applies from above for the video data |
| caption | String | |
| createdDate | Date | |
| id | String | |

**Core Data Manager class***: This class will be used for persisting (saving and retriving) the user's generated content. 

<details>
  <summary><b>CoreDataManager.swift</b></summary> 
  
```swift
class CoreDataManager {
  private init() {}
  static let shared = CoreDataManager()
  
  // NSManagedObjectContext instance from the AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  private var mediaObjects = [CDMediaObject]()
  
  // create
  public func createMediaObject(mediaURL: URL? = nil, imageData: Data) -> CDMediaObject {
    let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
    if let mediaURL = mediaURL {
      do {
        let videoData = try Data(contentsOf: mediaURL)
        mediaObject.videoData = videoData
      } catch {
        print("failed to convert url to data with error: \(error)")
      }
    }
    mediaObject.createdDate = Date()
    mediaObject.imageData = imageData
    mediaObject.mediaURL = mediaURL
    mediaObject.id = UUID().uuidString
    do {
      try context.save()
    } catch {
      print("failed to create media object with error: \(error)")
    }
    return mediaObject
  }
  
  // read
  public func fetchMediaObjects() -> [CDMediaObject] {
    do {
      mediaObjects = try context.fetch(CDMediaObject.fetchRequest())
    } catch {
      print("failed to fetch media objects with error: \(error)")
    }
    return mediaObjects
  }
  
  // update
  
  
  // delete
  public func deleteMediaObject(_ mediaObject: CDMediaObject) {
    context.delete(mediaObject)
    do {
      try context.save()
    } catch {
      print("failed to delete object with error: \(error)")
    }
  }
}
```
  
</details> 

#### Playing back video content from Core Data Binary Data 

Write an extension on Data that will convert a passed in Data object and get back a URL. This URL is needed to configure our AVPlayer(url: url).

```swift
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
````

#### Refactoring to swap local model (MediaObject) with the Core Data model (CDMediaObject)

Since we are now added Core Data and associated objects to our app we need to do some refactoring. 

MediaFeedViewController refactor to add Core Data objects
```swift 
```

MediaCell refactor to add Core Data objects
```swift 
```

## 15. Deleting a mediaObject 

#### Updated MediaCell
```swift 
protocol MediaCellDelegate: AnyObject {
  func didLongPress(_ mediaCell: MediaCell, mediaObject: CDMediaObject)
}

class MediaCell: UICollectionViewCell {
  
  @IBOutlet weak var mediaImageView: UIImageView!
  
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
  
  public func configureCell(for mediaObject: CDMediaObject, mediaSelected: MediaSelected) {
    self.mediaObject = mediaObject
    setImage(for: mediaObject)
    if mediaSelected == .image {
      //
    } else {
      //
    }
  }
}
````

#### Updated MediaFeedViewController 

Conforming to the MediaCellDelegate 

```swift 
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  //
  cell.delegate = self 
}
```

#### Conforming to the MediaCellDelegate 

Before we delete the object we will present an alert to the user and inform them that the delete action cannot be undone. This would be a best practice approach whenever deleting a user generated object.

```swift 
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
```

## 16. Update MediaCell with a play button icon

Add a UIImageView to the MediaCell in storyboard and select the **play.fill** SFSymbol. 

This play button should only show if the content is a video file. 

#### updated configureCell() in the MediaCell class

```swift 
public func configureCell(for mediaObject: CDMediaObject) {
  self.mediaObject = mediaObject
  setImage(for: mediaObject)
  if let _ = mediaObject.videoData { // is video
    playButtonIcon.isHidden = false
  } else {
    playButtonIcon.isHidden = true
  }
}
```


#### updated cellForItemAt() in the MediaFeedViewController class

```swift 
func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mediaCell", for: indexPath) as? MediaCell else {
    fatalError("could not dequeue a MediaCell")
  }
  let mediaObjet = mediaObjects[indexPath.row]
  cell.configureCell(for: mediaObjet)
  cell.delegate = self
  return cell
}
```

## 17. Updating the AVPlayer in the headerView to hold a strong reference 

When the user navigates to the AVPlayerViewController to play a selected video we want the player in the headerView to pause() playing. In order to achieve this we will update our code such that the player has a strong reference throughout the MediaFeedViewController. 

##### MediaFeedViewController

```swift 
private var player: AVPlayer!

override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  if let player = player {
    player.play()
  }
}

func playRandomVideo(in view: UIView) {
  let videoDataObjects  = mediaObjects.compactMap { $0.videoData }
  if let videoData = videoDataObjects.randomElement(),
    let videoURL = videoData.videoURLFromData() {
    player = AVPlayer(url: videoURL)
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = view.bounds
    playerLayer.videoGravity = .resizeAspect
    
    // remove all layers before adding a new one
    view.layer.sublayers?.removeAll()
    
    view.layer.addSublayer(playerLayer)
    
    player.play()
  }
}

extension MediaFeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // .......

    present(playerViewController, animated: true) {
      player.play()
      self.player.pause()
    }
  }
}
```

## 18. Other topics 

#### Using NSPredicate to filter data 

Here we can search for mediaObjects that contain the word ```awesome```. 

> [cd] ignore cases, ignores diacritics (accents)

```swift 
let request = CDMediaObject.fetchRequest() as NSFetchRequest<CDMediaObject>
request.predicate = NSPredicate(format: "caption CONTAINS[cd] %@", "Awesome")
do {
  mediaObjects = try context.fetch(request)
} catch {
  print("failed to fetch media objects with error: \(error)")
}
```


## So much more can be done.....

App is complete and now persists user generated media content. Many places to go from here. AVFoundation and Core Data are huge frameworks in iOS and there is so much more functionality and features of those frameworks. Please feel free to explore and build upon this introductory lesson. 

#### Additional Resources 

1. [Media Assets, Playback, and Editing](https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing)
2. [StackOverflow - photo library vs saved photos album](https://stackoverflow.com/questions/8233238/whats-the-difference-between-camera-roll-and-photo-library)


