//
//  SignUpViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.backgroundColor = .black
        usernameTextField.tintColor = .white
        usernameTextField.textColor = .white
        usernameTextField.attributedPlaceholder = NSAttributedString(string: usernameTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white:1.0, alpha: 0.6)])
        let usernameTextFieldBottomLayerLine = CALayer()
        usernameTextFieldBottomLayerLine.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        usernameTextFieldBottomLayerLine.backgroundColor = UIColor(colorLiteralRed: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        usernameTextField.layer.addSublayer(usernameTextFieldBottomLayerLine)
        
        emailTextField.backgroundColor = .black
        emailTextField.tintColor = .white
        emailTextField.textColor = .white
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white:1.0, alpha: 0.6)])
        let emailTextFieldBottomLayerLine = CALayer()
        emailTextFieldBottomLayerLine.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        emailTextFieldBottomLayerLine.backgroundColor = UIColor(colorLiteralRed: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        emailTextField.layer.addSublayer(emailTextFieldBottomLayerLine)
        
        passwordTextField.backgroundColor = .black
        passwordTextField.tintColor = .white
        passwordTextField.textColor = .white
        passwordTextField.attributedPlaceholder = NSAttributedString(string: passwordTextField.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor(white:1.0, alpha: 0.6)])
        let passwordTextFieldBottomLayerLine = CALayer()
        passwordTextFieldBottomLayerLine.frame = CGRect(x: 0, y: 29, width: 1000, height: 0.6)
        passwordTextFieldBottomLayerLine.backgroundColor = UIColor(colorLiteralRed: 50/255, green: 50/255, blue: 25/255, alpha: 1).cgColor
        passwordTextField.layer.addSublayer(passwordTextFieldBottomLayerLine)
        
        profileImage.layer.cornerRadius = 40
        profileImage.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        handleTextField()
    }
    
    func handleTextField() {
        usernameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        guard let username = usernameTextField.text, !username.isEmpty, let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.isEnabled = false
            signUpButton.setTitleColor(UIColor.lightText, for: .normal)
            return
        }
        signUpButton.setTitleColor(UIColor.white, for: .normal)
        signUpButton.isEnabled = true
    }
    
    func didTapProfileImageView() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func dismissSignUpVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signUpButton(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user: User?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let userId = user?.uid
            
            let storageReference = Storage.storage().reference().child("profile_image").child(userId!)
            if let profileImage = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageReference.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        return
                    }
                    let profileImageUrl = metadata?.downloadURL()?.absoluteString
                    self.setUserInformation(profileImageURl: profileImageUrl!, username: self.usernameTextField.text!, email: self.emailTextField.text!, uid: userId!)
                })
            }
        }
    }
    
    func setUserInformation(profileImageURl: String, username: String, email: String, uid: String) {
        
        var reference: DatabaseReference!
        reference = Database.database().reference()
        let userReference = reference.child("users")
        let newUserReference = userReference.child(uid)
        newUserReference.setValue(["username":username, "email":email, "profileImageUrl":profileImageURl])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        usernameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("Did finish picking media")
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = image
            profileImage.image  = image
        }
        dismiss(animated: true, completion: nil)
    }
}
