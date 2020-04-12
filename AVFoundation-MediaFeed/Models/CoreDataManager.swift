//
//  CoreDataManager.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/12/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit
import CoreData

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
