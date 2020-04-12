//
//  CDMediaObject+CoreDataProperties.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/12/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//
//

import Foundation
import CoreData


extension CDMediaObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDMediaObject> {
        return NSFetchRequest<CDMediaObject>(entityName: "CDMediaObject")
    }

    @NSManaged public var imageData: Data?
    @NSManaged public var mediaURL: URL?
    @NSManaged public var caption: String?
    @NSManaged public var createdDate: Date?
    @NSManaged public var id: String?
    @NSManaged public var videoData: Data?
    @NSManaged public var videoFilename: String?

}
