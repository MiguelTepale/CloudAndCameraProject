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
    
}
