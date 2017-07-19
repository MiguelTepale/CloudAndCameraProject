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
    func photoFinishedDownloading()
    func URLsFinishedDownloading()
}

class NetworkCall: NSObject {
    
    static var delegate:NetworkCallDelegate?
    static let imageCache = NSCache<AnyObject, AnyObject>()
    static var index = 0
    static var photos = [Photo]()
    
    static func initializePhotoURLDownloadFromFirebase(_ url:String) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON(completionHandler: {response in
            
            //If internet is offline, return the method so that it doesn't break the app
            if response.error != nil {
                print(response.error!)
                return
            }
            
            //one giant dictionary...
            guard let results = response.result.value as? [String : Any] else {
                return
            }
            
            //Obtain image url...
            for result in results.values{
                guard let result = result as? [String:Any] else {
                    print("The Dictionary is nil in loadUploadedUserPhotos")
                    return
                }
                guard let urlString = result["photoUrl"] as? String else {
                    print("result[photoUrl is nil")
                    continue
                }
                guard let photoName = result["photoName"] as? String else {
                    print("result[photoName] is nil")
                    continue
                }
                
                let photo = Photo()
                
                //set imageURL
                let imageURL = URL(string: urlString)
                photo.url = imageURL!
                
                //set imageName
                photo.storageId = photoName
                
                photos.append(photo)
            }
            //Obtain key value...
            for key in results.keys {
                photos[index].referenceId = key
                index+=1
            }
            delegate?.URLsFinishedDownloading()
        })
    }

    static func downloadPhotoToCollectionView(_ photo:Photo, forImageView imageView: UIImageView) {
        
        if let imageFromCache = imageCache.object(forKey:(photo.url?.absoluteString)! as AnyObject) {
            photo.image = imageFromCache as! UIImage
            DispatchQueue.main.async {
                imageView.image = photo.image
            }
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
                
                DispatchQueue.main.async {
                    imageView.image = photo.image
                }
                }
                .resume()
        }
    }
    
    static func downloadPhoto(_ photo:Photo) {
        
        URLSession.shared.dataTask(with: photo.url!) { data, response, error in
            guard let urlData = data, error == nil else {
                return
            }
            
            let imageToCache = UIImage(data: urlData)
            let urlKey = photo.url!.absoluteString
            imageCache.setObject(imageToCache!, forKey: urlKey as AnyObject)
            
            photo.image = imageToCache!
            
            DispatchQueue.main.async {
                delegate?.photoFinishedDownloading()
            }
            }
            .resume()
    }
        
}
