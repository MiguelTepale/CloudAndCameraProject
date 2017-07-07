//
//  NetworkCall.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 7/5/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol NetworkCallDelegate {
    func photosFinishedDownloading(_ didFinish:Bool)
}

class NetworkCall: NSObject {
    
    static var delegate:NetworkCallDelegate?
    static var photos = [Photo]()
    static let imageCache = NSCache<AnyObject, AnyObject>()
    
    static func initializePhotoURLDownloadFromFirebase(_ url:String) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON(completionHandler: {response in
            
            //one giant dictionary...
            let results = response.result.value as! [String : Any]
//            let test = results.keys as! String
            

            for result in results.values{
                
                guard let result = result as? [String:Any] else {
                    print("The Dictionary is nil in loadUploadedUserPhotos")
                    return
                }
                if let urlString = result["photoUrl"] as? String {
                    let photo = Photo()
                    let imageURL = URL(string: urlString)
                    photo.url = imageURL!
                    photos.append(photo)
                }
            }
            var index = 0
            for key in results.keys{
                photos[index].id = key
                index+=1
            }
            self.downloadPhotos(photos)
        })
    }

    static func downloadPhotos(_ photos:Array<Photo>) {
        
        for photo in photos {
            
            if let imageFromCache = imageCache.object(forKey:(photo.url?.absoluteString)! as AnyObject) {
                photo.image = imageFromCache as! UIImage
                DispatchQueue.main.async {
                    delegate?.photosFinishedDownloading(true)
                }
                continue
            }
            else {
                URLSession.shared.dataTask(with: photo.url!) { data, response, error in
                    guard let urlData = data, error == nil else {
                        return
                    }
                    
                    let imageToCache = UIImage(data: urlData)
                    let urlKey = photo.url!.absoluteString
                    imageCache.setObject(imageToCache!, forKey: urlKey as AnyObject)
                    photo.image = imageToCache!
                    photo.hasDownloaded = true
                    
                    DispatchQueue.main.async {
                        delegate?.photosFinishedDownloading(true)
                    }
                    }
                    .resume()
            }
        }
    }
    
    static func retrieveCurrentPhotoURLS() {
        
        for photo in photos {
            if photo.hasDownloaded == true {
                if let imageFromCache = imageCache.object(forKey:(photo.url?.absoluteString)! as AnyObject) {
                    photo.image = imageFromCache as! UIImage
                    DispatchQueue.main.async {
                        delegate?.photosFinishedDownloading(true)
                    }
                    continue
                }
            }
            else {
                self.downloadPhoto(photo.url!,photo)
            }
        }
    }
    
    static func downloadPhoto(_ url:URL, _ photo:Photo) {
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let urlData = data, error == nil else {
                return
            }
            
            let imageToCache = UIImage(data: urlData)
            let urlKey = photo.url!.absoluteString
            imageCache.setObject(imageToCache!, forKey: urlKey as AnyObject)

            photo.image = imageToCache!
            photo.hasDownloaded = true
            
            DispatchQueue.main.async {
                delegate?.photosFinishedDownloading(true)
            }
            }
            .resume()
    }
    
}
