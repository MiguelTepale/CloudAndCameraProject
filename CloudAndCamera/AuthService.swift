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

class AuthService {
    
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
        let photoReferenceID = reference.child("user_images").child(photo.id!).child("comments").childByAutoId().key
        let photoReference = reference.child("user_images").child(photo.id!).child("comments").child(photoReferenceID)
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
    
    static func downloadCommentsFromFirebase(_ photo:Photo) {
        
    }

}
