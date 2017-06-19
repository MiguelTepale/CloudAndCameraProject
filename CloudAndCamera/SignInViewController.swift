//
//  SignInViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseAuth

import FirebaseStorage

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        signInButton.isEnabled = false
        
        handleTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        emailTextField.text = ""
        passwordTextField.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func handleTextField() {
        
        emailTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else {
            self.signInButton.isEnabled = false
            self.signInButton.setTitleColor(UIColor.lightText, for: .normal)
            return
        }
        self.signInButton.setTitleColor(UIColor.white, for: .normal)
        self.signInButton.isEnabled = true
    }
    
    @IBAction func didAuthenticateUser(_ sender: UIButton) {
        AuthService.signInUser(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            print("onSuccess succeeded")
            self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
        }, onError: { error in
        print(error!)
        })
    }
    
    //Create a completion handler to deal with emptying all textfields
    //Miguel: Please the second option
    //Or use 'viewWillDisappear' or 'viewDidDisappear'
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToSignUpVC" {
//            emailTextField.text = ""
//            passwordTextField.text = ""
//        }
//    }
    
}
