//
//  DetailViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 6/20/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var photo = Photo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = photo.image
    }
    
}
