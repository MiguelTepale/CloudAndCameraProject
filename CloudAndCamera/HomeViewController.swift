//
//  HomeViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        NetworkCall.delegate = self
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: width / 3, height: width / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0 
        collectionView.collectionViewLayout = layout
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
        NetworkCall.retrievePhotoURLS("https:cloudandcamera-8f82b.firebaseio.com/user_images.json")
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
        return NetworkCall.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell ?? PhotoCell()
//        cell.reuseIdentifier = " PhotoCell"

        let currentPhoto = NetworkCall.photos[indexPath.row]
    
        cell.imageView.image = currentPhoto.image
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
}

extension HomeViewController: NetworkCallDelegate {
    func photosFinishedDownloading(_ didFinish: Bool) {
        
        if didFinish == true {
            collectionView.reloadData()
        }
    }
}
