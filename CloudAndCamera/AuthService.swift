//
//  AuthService.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/18/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol AuthServiceDelegate {
    func commentsFinishedDownloadingFromFirebase(_ photo: Photo)
}

class AuthService {
    
    static var delegate:AuthServiceDelegate?
    
    static func signInUser(email: String, password: String, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMesage:String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func signUpUser(username: String, email: String, password: String, imageData: Data, onSuccess:@escaping () -> Void, onError:@escaping (_ errorMesage:String?) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let userId = user?.uid
            
            let storageReference = Storage.storage().reference(forURL:Config.storageRootReference).child("profile_image").child(userId!)
            
            storageReference.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil {
                    return
                }
                let profileImageUrl = metadata?.downloadURL()?.absoluteString
                self.setUserInformation(profileImageURl: profileImageUrl!, username:username, email: email, uid: userId!, onSuccess: onSuccess)
            })
        }
    }
    
    static func setUserInformation(profileImageURl: String, username: String, email: String, uid: String, onSuccess:@escaping () -> Void) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        let userReference = reference.child("users")
        let newUserReference = userReference.child(uid)
        newUserReference.setValue(["username":username, "email":email, "profileImageUrl":profileImageURl])
        onSuccess()
    }
    
    static func sendCommentToFirebase(photo: Photo,comment: Comment) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        let photoReferenceID = reference.child("user_images").child(photo.referenceId!).child("comments").childByAutoId().key
        let photoReference = reference.child("user_images").child(photo.referenceId!).child("comments").child(photoReferenceID)
        photoReference.setValue(["comment":comment.consumerComment, "userID":comment.consumerID, "username":comment.consumerUsername])
        comment.firebaseID = photoReferenceID
    }
    
    static func retreiveCurrentUsername(userID: String) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        reference.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [String:Any] else {
                print("\(userID) dictionary in 'retreiveCurrentUsername' method is nil")
                return
            }
            let username = value["username"] as! String
            Consumer.username = username
        }
    )}
    
    static func setLikesLabel(photo: Photo, likesLabel:UILabel) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        reference.child("user_images").child(photo.referenceId!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let value = snapshot.value as? [String:Any] else {
                print("\(photo.referenceId!) dictionary in 'retreiveCurrentUsername' method is nil")
                return
            }
            
            guard let likes = value["likes"] as? Int else {
                print("likes is nil")
                return
            }
            
            DispatchQueue.main.async {
                let number = String(likes)
                likesLabel.text = number
            }
        }
    )
    }
    
    static func downloadCommentsFromFirebase(_ photo:Photo) {
        
        if photo.commentsHaveDownloaded == true {
            return
        }
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        reference.child("user_images").child(photo.referenceId!).child("comments").observeSingleEvent(of:DataEventType.value, with: { (snapshot) in
            
            guard let results = snapshot.value as? [String:Any] else {
                print("\(String(describing: photo.referenceId)) dictionary does not exist in 'downloadCommentsFromFirebase'")
                return
            }
            
            for result in results.values {
                
                guard let result = result as? [String:Any] else {
                    print("Result dictionary is nil in 'downloadCommentsFromFirebase'")
                    return
                }
                guard let userComment = result["comment"] as? String else{
                    print("comment doesn't exist in results.value dictionary")
                    continue
                }
                guard let userID = result["userID"] as? String else{
                    print("userID doesn't exist in results.value dictionary")
                    continue
                }
                guard let username = result["username"] as? String else {
                    print("username doesn't exist in results.value dictionary")
                    continue
                }
                
                let comment = Comment()
                comment.consumerComment = userComment
                comment.consumerID = userID
                comment.consumerUsername = username
                
                photo.comments.append(comment)
            }
            DispatchQueue.main.async {
                delegate?.commentsFinishedDownloadingFromFirebase(photo)
            }
        })
    }
    
    static func deletePhotoFromReference(photo: Photo) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        reference.child("user_images").child(photo.referenceId!).removeValue(completionBlock: { (error, DataBaseReference) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
        })
    }
    
    static func deletePhotoFromStorage(photo: Photo) {
        
        let storage = Storage.storage().reference(forURL:Config.storageRootReference).child("user_images").child(photo.storageId!)
        storage.delete(completion: {(error) in
            
            if error != nil {
                print(error!.localizedDescription)
            }
        })
    }
    
}
