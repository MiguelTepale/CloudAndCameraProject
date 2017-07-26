//
//  Photo.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/30/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import Foundation

class Photo: NSObject {
    
    var comments = [Comment]()
    var commentsHaveDownloaded = false
    var hasBeenLiked = Bool()
    var image = UIImage()
    var referenceId: String?
    var storageId: String?
    var totalLikes: String?
    var url = URL(string: "https://www.google.com")
    
}
