//
//  HomeViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var userURLS = [URL]()
    var userPhotos = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: width / 3, height: width / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        retrievePhotoURLS()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func retrievePhotoURLS() {
        
        let url = "https://cloudandcamera-8f82b.firebaseio.com/user_images.json"
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON(completionHandler: {response in
            
            //one giant dictionary...
            let results = response.result.value as! [String : Any]
            
            for result in results.values{
                
                guard let result = result as? [String:Any] else {
                    print("The Dictionary is nil in loadUploadedUserPhotos")
                    return
                }
                if let urlString = result["photoUrl"] as? String {
                    let imageURL = URL(string: urlString)
                    self.userURLS.append(imageURL!)
                }
            }
            self.downloadPhotos(self.userURLS)
        })
    }
    
    //SDWebImage for caching
    //Or follow "Build that app" tutorial on caching images
    func downloadPhotos(_ userURLS:Array<URL>) {
        
        for url in userURLS {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let urlData = data, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let userImage = UIImage(data: urlData)
                    self.userPhotos.append(userImage!)
                    self.collectionView.reloadData()
                }
                }
                .resume()
        }
    }

    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        
        print(Auth.auth().currentUser!)
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        let startStoryboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = startStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userPhotos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell ?? PhotoCell()
//        cell.reuseIdentifier = " PhotoCell"

        let currentPhoto = userPhotos[indexPath.row]
    
        cell.imageView.image = currentPhoto
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
}
