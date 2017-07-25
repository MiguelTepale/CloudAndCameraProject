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
    var photoHasBeenDeleted = false
    
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
        if photoHasBeenDeleted == true {
            collectionView.reloadData()
            photoHasBeenDeleted = false
        }
    }

    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        
        print(Auth.auth().currentUser!)
        do {
            try Auth.auth().signOut()
        }
        catch let logoutError {
            print(logoutError)
            return
        }
        
        //Empty NSCache!
        NetworkCall.imageCache.removeAllObjects()
        
        //Reset properties before logging out...
        NetworkCall.photos.removeAll()
        NetworkCall.index = 0
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        //Segue back to login screen
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
        NetworkCall.downloadPhotoToCollectionView(currentPhoto, forImageView: cell.imageView)
    
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "segueToDetailVC", sender: indexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToDetailVC" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            let currentPhoto = NetworkCall.photos[sender as! Int]
            AuthService.downloadCommentsFromFirebase(currentPhoto)
            AuthService.retrieveTotalNumberOfLikes(photo: currentPhoto)
            AuthService.setLikeButton(photo: currentPhoto, consumerID: Consumer.id)
            
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.photo = currentPhoto
            detailViewController.indexPathRow = sender as! Int
        }
    }

}

extension HomeViewController: NetworkCallDelegate {
    func URLsFinishedDownloading() {
        collectionView.reloadData()
    }
    
    func photoFinishedDownloading() {
        //I love this method. This only updates a cell by creating new indexPath to the cell that you want to update.
        let newPhotoIndexPath = IndexPath(row: NetworkCall.photos.count-1, section: 0)
        collectionView.insertItems(at: [newPhotoIndexPath])
    }
    
}
