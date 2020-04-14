//
//  CoreDataManager.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/14/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager {
  
  // creating a singleton
  private init() {}
  static let shared = CoreDataManager()
  
  private var mediaObjects = [CDMediaObject]()
  
  // get instance of the NSManagedObjectContext from the AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  // NSManagedObjectContext does saving, fetching on NSMangedObjects....
  
  // CRUD - create
  // converting a UIImage to Data
  func createMediaObect(_ imageData: Data, videoURL: URL?) -> CDMediaObject {
    let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
    mediaObject.createdDate = Date() // current date
    mediaObject.id = UUID().uuidString // unique string
    mediaObject.imageData = imageData // both video and image objects has an image
    if let videoURL = videoURL { // if exist, this means it's a video object
      // convert a URL to Data
      do {
        mediaObject.videoData = try Data(contentsOf: videoURL)
      } catch {
        print("failed to convert URL to Data with error: \(error)")
      }
    }
    
    // save the newly created mediaObject entity instance to the NSManagedObjectContext
    do {
      try context.save()
    } catch {
      print("failed to save newly created media object with error: \(error)")
    }
    return mediaObject
  }
  
  // read
  func fetchMediaObjects() -> [CDMediaObject] {
    do {
      mediaObjects = try context.fetch(CDMediaObject.fetchRequest()) // fetch all the created objects from the CDMediaObject entity
    } catch {
      print("failed to fetch media objects with error: \(error)")
    }
    return mediaObjects
  }
  
  // update
  
  // delete
  
}
