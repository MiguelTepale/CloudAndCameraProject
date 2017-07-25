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
    var image = UIImage()
    var referenceId: String?
    var storageId: String?
    var url = URL(string: "https://www.google.com")
    var commentsHaveDownloaded = false
    var totalLikes: String?
    var hasBeenLiked = Bool()
    
}
