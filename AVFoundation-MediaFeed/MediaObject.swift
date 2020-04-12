//
//  MediaObject.swift
//  AVFoundation-MediaFeed
//
//  Created by Alex Paul on 4/11/20.
//  Copyright © 2020 Alex Paul. All rights reserved.
//

import Foundation

struct MediaObject {
  let imageData: Data?
  let mediaURL: URL?
  let caption: String?
  let createdDate = Date()
  let id = UUID().uuidString
}
