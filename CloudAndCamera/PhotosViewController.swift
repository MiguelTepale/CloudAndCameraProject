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

    @IBOutlet weak var takePhotoStackView: UIStackView!
    @IBOutlet weak var uploadPhotoStackView: UIStackView!
    
    var selectedImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let takePhotoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTakePhotoStackView))
        takePhotoStackView.addGestureRecognizer(takePhotoTapGesture)
        takePhotoStackView.isUserInteractionEnabled = true
        
        let uploadPhotoTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapUploadPhotoStackView))
        uploadPhotoStackView.addGestureRecognizer(uploadPhotoTapGesture)
        uploadPhotoStackView.isUserInteractionEnabled = true
    }
    
    func didTapUploadPhotoStackView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    func didTapTakePhotoStackView() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func sendDataToDatabase(photoUrl: String,_ photo:Photo) {
        var reference: DatabaseReference!
        reference = Database.database().reference()
        let userImagesReference = reference.child("user_images")
        let newUserImagesId = userImagesReference.childByAutoId().key
        let newUserImagesReference = userImagesReference.child(newUserImagesId)
        newUserImagesReference.setValue(["photoUrl":photoUrl, "photoName":photo.storageId!], withCompletionBlock: {(error, reference) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            //set key and append new photo object
            photo.referenceId = newUserImagesId
            NetworkCall.photos.append(photo)
            ProgressHUD.showSuccess("Success")
            NetworkCall.downloadPhoto(photo)
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
                let photo = Photo()
                let photoImageUrl = URL(string: photoUrl!)
                //set image url and storageID...
                photo.url = photoImageUrl
                photo.storageId = photoIdString
                self.sendDataToDatabase(photoUrl: photoUrl!,photo)
            })
        } else {
            ProgressHUD.showError("Profile image can't be empty")
        }
        dismiss(animated: true, completion: nil)
    }
}
