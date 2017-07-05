//
//  PhotoCell.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/28/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import Foundation
import UIKit
import Alamofire


protocol photoCellDelegate {
    func photosFinishedDownloading(_ didFinish:Bool)
}

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    static var delegate:photoCellDelegate?
    static var photos = [Photo]()
    
    static func retrievePhotoURLS(_ url:String) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON(completionHandler: {response in
            
            //one giant dictionary...
            let results = response.result.value as! [String : Any]
            
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
            self.downloadPhotos(photos)
        })
    }
    
    static func downloadPhotos(_ photos:Array<Photo>) {
        
        for photo in photos {
            URLSession.shared.dataTask(with: photo.url!) { data, response, error in
                guard let urlData = data, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let userImage = UIImage(data: urlData)
                    photo.image = userImage!
                    delegate?.photosFinishedDownloading(true)
                }
                }
                .resume()
        }
    }
    
}

