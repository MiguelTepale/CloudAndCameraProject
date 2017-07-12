//
//  DetailViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/20/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    

    @IBOutlet weak var customButtonStripView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addCommentSeachBar: UISearchBar!
    var photo = Photo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo.image
        
        let bottomLineBorder = CALayer()
        bottomLineBorder.backgroundColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0).cgColor
        bottomLineBorder.frame = CGRect(x: 0, y: 57, width: customButtonStripView.frame.size.width, height: 0.8)
        customButtonStripView.layer.addSublayer(bottomLineBorder)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        addCommentSeachBar.resignFirstResponder()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            //Figure out where the 20 points have gone.
            if self.view.frame.origin.y == 64{
                self.view.frame.origin.y -= keyboardSize.height

            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
