//
//  CoreDataManager.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/12/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import UIKit

class CoreDataManager {
  private init() {}
  static let shared = CoreDataManager()
  
  // NSManagedObjectContext instance from the AppDelegate
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  private var mediaObjects = [CDMediaObject]()
  
  public func createMediaObject(mediaURL: URL? = nil, imageData: Data) {
    let mediaObject = CDMediaObject(entity: CDMediaObject.entity(), insertInto: context)
    mediaObject.createdDate = Date()
    mediaObject.imageData = imageData
    mediaObject.mediaURL = mediaURL
    mediaObject.id = UUID().uuidString
    do {
      try context.save()
    } catch {
      print("failed to create media object with error: \(error)")
    }
  }
  
  public func fetchMediaObjects() -> [CDMediaObject] {
    do {
      mediaObjects = try context.fetch(CDMediaObject.fetchRequest())
    } catch {
      print("failed to fetch media objects with error: \(error)")
    }
    return mediaObjects
  }
}
