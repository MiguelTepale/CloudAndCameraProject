//
//  HomeViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/14/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        print(Auth.auth().currentUser!)
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let startStoryboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = startStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
    }
    
}
