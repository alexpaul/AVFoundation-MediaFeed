# AVFoundation-MediaFeed


Introduction to AVFoundation and AVKit frameworks.

In this lesson we will be building an app that captures video and plays back the content in a **CALayer** or the built-in AVPlayerViewController.

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









