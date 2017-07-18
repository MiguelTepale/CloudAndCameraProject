//
//  DetailViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/20/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //UI Elements
    @IBOutlet weak var customButtonStripView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addCommentSeachBar: UISearchBar!
    @IBOutlet weak var commentsTableView: UITableView!
    
    //Properties
    var photo = Photo()
    
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
        
        AuthService.downloadCommentsFromFirebase(photo)
        
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

extension DetailViewController: AuthServiceDelegate {
    
    func commentsFinishedDownloadingFromFirebase(_ photo: Photo) {
        
        commentsTableView.reloadData()
        photo.commentsHaveDownloaded = true
    }
}
