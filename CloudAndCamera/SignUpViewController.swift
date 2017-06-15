//
//  SignUpViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

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
    }
    
    @IBAction func dismissSignUpVC(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
