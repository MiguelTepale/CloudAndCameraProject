//
//  DetailViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/20/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class DetailViewController: UIViewController, UIAlertViewDelegate {

    //UI Elements
    @IBOutlet weak var customButtonStripView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addCommentSeachBar: UISearchBar!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    //Properties
    var photo = Photo()
    var indexPathRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo.image
        
        AuthService.delegate = self
        addCommentSeachBar.delegate = self
        
        let bottomLineBorder = CALayer()
        bottomLineBorder.backgroundColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0).cgColor
        bottomLineBorder.frame = CGRect(x: 0, y: 57, width: customButtonStripView.frame.size.width, height: 0.8)
        customButtonStripView.layer.addSublayer(bottomLineBorder)
        
        let removeIconOf = addCommentSeachBar.value(forKey: "searchField") as! UITextField
        removeIconOf.leftViewMode = UITextFieldViewMode.never
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let commentsTableViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCommentsTableView))
        commentsTableView.addGestureRecognizer(commentsTableViewTapGesture)
        commentsTableView.isUserInteractionEnabled = true
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        addCommentSeachBar.resignFirstResponder()
    }
    
    func didTapCommentsTableView() {
        addCommentSeachBar.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //Figure out where the 20 points have gone.
            if self.view.frame.origin.y == 64{
                self.view.frame.origin.y -= keyboardSize.height

            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func likePhotoButton(_ sender: UIButton) {
        
        //Update button and like label..
        if photo.hasBeenLiked == true {
            let totalLikesString = photo.totalLikes
            var currentCount = Int(totalLikesString!)
            currentCount! -= 1
            guard let newTotalLikesString = currentCount else {
                print("'newTotalLikesString' is nil")
                return
            }
            photo.totalLikes = String(newTotalLikesString)
            photo.hasBeenLiked = false
            if let image = UIImage(named: "icn_like") {
                likeButton.setImage(image, for:.normal)
            }
            numberOfLikesLabel.text = photo.totalLikes
        }
        else {
            let totalLikesString = photo.totalLikes
            var currentCount = Int(totalLikesString!)
            currentCount! += 1
            guard let newTotalLikesString = currentCount else {
                print("'newTotalLikesString' is nil")
                return
            }
            photo.totalLikes = String(newTotalLikesString)
            photo.hasBeenLiked = true
            if let image = UIImage(named: "activeSkinny") {
                likeButton.setImage(image, for:.normal)
            }
            numberOfLikesLabel.text = photo.totalLikes
        }
    
        //Send changes to Firebase..
        var reference: DatabaseReference!
        reference = Database.database().reference().child("user_images").child(photo.referenceId!)
        
        reference.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            
            if var post = currentData.value as? [String : AnyObject], let uid = Auth.auth().currentUser?.uid {
                
                var usersWhoLiked: Dictionary<String, Bool>
                
                usersWhoLiked = post["usersWhoLiked"] as? [String : Bool] ?? [:]
                var likes = post["likes"] as? Int ?? 0
                if let _ = usersWhoLiked[uid] {
                    // Unstar the like and remove self from like
                    likes -= 1
                    usersWhoLiked.removeValue(forKey: uid)
                } else {
                    // Star the like and add self to like
                    likes += 1
                    usersWhoLiked[uid] = true
                }
                post["likes"] = likes as AnyObject?
                post["usersWhoLiked"] = usersWhoLiked as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    @IBAction func commentsButton(_ sender: UIButton) {
        
        performSegue(withIdentifier: "segueToTableVC", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "segueToTableVC" {
            let backItem = UIBarButtonItem()
            backItem.title = "Back"
            navigationItem.backBarButtonItem = backItem
            
            let tableViewController = segue.destination as! TableViewController
            tableViewController.photo = photo
        }
        
    }
    
    @IBAction func deletePhotoButton(_ sender: UIButton) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deletePhotoAction = UIAlertAction(title: "Delete Photo", style:.destructive, handler: {(alert: UIAlertAction!) -> Void
            in
            
            AuthService.deletePhotoFromReference(photo: self.photo)
            AuthService.deletePhotoFromStorage(photo:self.photo)
            NetworkCall.photos.remove(at: self.indexPathRow)
            let homeViewController = self.navigationController?.viewControllers[0] as! HomeViewController
            homeViewController.photoHasBeenDeleted = true
            self.navigationController?.popToRootViewController(animated: true)
            })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deletePhotoAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
}

extension DetailViewController: AuthServiceDelegate {
    
    func commentsFinishedDownloadingFromFirebase(_ photo: Photo) {
        commentsTableView.reloadData()
        photo.commentsHaveDownloaded = true
    }
    func totalLikesRetrieved(photo: Photo) {
        numberOfLikesLabel.text = photo.totalLikes
    }
    func likeButtonWillSet(photo: Photo) {
        if photo.hasBeenLiked == true {
            if let image = UIImage(named: "activeSkinny") {
                self.likeButton.setImage(image, for:.normal)
            }
        }
    }
}

extension DetailViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        //Create comment object
        let currentComment = searchBar.text
        searchBar.text = ""
        let comment = Comment()
        comment.consumerComment = currentComment!
        comment.consumerID = Consumer.id
        comment.consumerUsername = Consumer.username
        
        //Send comment to Firebase
        AuthService.sendCommentToFirebase(photo: photo, comment: comment)
        
        //Append comment with added firebaseID property
        photo.comments.append(comment)
        
        //Now that the comment has been initialized, add to the tableView
        let newPhotoIndexPath = IndexPath.init(row: photo.comments.count-1, section: 0)
        commentsTableView.insertRows(at: [newPhotoIndexPath], with: UITableViewRowAnimation.automatic)
        photo.commentsHaveDownloaded = true
        
    }
}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photo.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell

        cell.usernameLabel.text = photo.comments[indexPath.row].consumerUsername
        cell.commentLabel.text = photo.comments[indexPath.row].consumerComment
        
        return cell
    }
}
