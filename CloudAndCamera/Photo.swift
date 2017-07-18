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
    var id : String?
    var image = UIImage()
    var url = URL(string: "https://www.google.com")
    var commentsHaveDownloaded = false
    
}
