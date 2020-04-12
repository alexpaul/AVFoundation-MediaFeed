# AVFoundation-MediaFeed


Introduction to AVFoundation and AVKit frameworks.

In this lesson we will be building an app that captures video and plays back the content in a **CALayer** or the built-in **AVPlayerViewController**.

## Objectives 

1. Capture video using UIImagePickerController 
1. Play video using AVPlayerViewController 
1. Generate video preview usign AVAssetImageGenerator 
1. Play video using a CALayer 
1. Persist video (here we can use APIs we have seen before: FileManager and documents directory, more recently Core Data) 

## 1. AVFoundation 

> Apple documentation: The AVFoundation framework combines four major technology areas that together encompass a wide range of tasks for capturing, processing, synthesizing, controlling, importing and exporting audiovisual media on Apple platforms.

## 2. Let's begin 

Create a new Xcode project. Our app will be called AVFoundation-MediaFeed. 

## 3. Overview of user interface for the app

The app will be embedded in a UINavigationController. In the navigation bar we will have two UIBarButtonItems, a button for selecting the devices video capture and the second button will retrieve content from the user's media library. 

We will use a collection view to display user generated content. The collection view will have a supplementary header view that displays the last seen of played content. The cells of the collection view will either display an image of a still image taken or a video preview in the case of the user doing video capture. 

## 4. ViewController 

Refactor the ViewController and call it **MediaFeedViewController**. Go to the storyboard and embedd the one scene into a UINavigationController. 

Add two UIBarButtonItem 's to the navigation bar. Select **photo.fill** and **video.fill** respectively from the attributes inspector. 

Set the navigation title to **Media Feed** 

Drag in a collection view to the view controller scene and set its constraints to 0 at all safe area edges (top, leading, bottom and trailing) 

Set the cell's ```reuse identifier``` to **mediaCell** 

As per the cell in the collection view set the size to 340 X 340. We will further configure the exact size in the view controller's ```sizeForItem(:_)``` method. 

Drag in an image view to the cell, set the constraints to 0 all around. Feel free to set a default image on the image view.

The scrolling direction of our collection view will remain vertical. 

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
  imagePickerController.sourceType = .savedPhotosAlbum
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

#### Keep track of selected media in the MediaFeedViewController 

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


## 11. Making a video preview (Welcome AVFoundation)

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

#### AVAssetImageGenerator 

#### CMTime 

#### CGImage 

#### appliesPreferredTrackTransform() 

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


