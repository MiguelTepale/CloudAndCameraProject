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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    @IBAction func logoutButton(_ sender: UIBarButtonItem) {
        print(Auth.auth().currentUser!)
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        let startStoryboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = startStoryboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: true, completion: nil)
    }
    
}
