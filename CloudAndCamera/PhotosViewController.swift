//
//  PhotosViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class PhotosViewController: UIViewController {

    @IBOutlet weak var uploadPhotoStackView: UIStackView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapPhotoStackView))
        uploadPhotoStackView.addGestureRecognizer(tapGesture)
        uploadPhotoStackView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func didTapPhotoStackView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func sendDataToDatabase(photoUrl: String) {
        var reference: DatabaseReference!
        reference = Database.database().reference()
        let userImagesReference = reference.child("user_images")
        let newUserImagesId = userImagesReference.childByAutoId().key
        let newUserImagesReference = userImagesReference.child(newUserImagesId)
        newUserImagesReference.setValue(["photoUrl":photoUrl], withCompletionBlock: {(error, reference) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Success")
        })
    }
    
}

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Did finish picking photo in camera")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
        }
        
        ProgressHUD.show("Uploading...", interaction: false)
        if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
            let photoIdString = NSUUID().uuidString
            
            let storageReference = Storage.storage().reference(forURL:Config.storageRootReference).child("user_images").child(photoIdString)
            storageReference.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil {
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                let photoUrl = metadata?.downloadURL()?.absoluteString
                self.sendDataToDatabase(photoUrl: photoUrl!)
            })
        } else {
            ProgressHUD.showError("Profile image can't be empty")
        }
        
        dismiss(animated: true, completion: nil)
    }
}
