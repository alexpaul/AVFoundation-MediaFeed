//
//  MediaObject.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/13/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

// mediaObject instance can either be a video or ab image
struct MediaObject: Codable {
  let imageData: Data?
  let videoURL: URL? 
  let caption: String? // UI so user enter text
  let id = UUID().uuidString
  let createDate = Date()
}
