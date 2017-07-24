//
//  TableViewController.swift
//  CloudAndCamera
//
//  Created by Miguel Tepale on 7/23/17.
//  Copyright © 2017 Miguel Tepale. All rights reserved.
//

import UIKit

class TableViewController: UIViewController {
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    var photo = Photo()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension TableViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photo.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        cell.detailTextLabel?.text = photo.comments[indexPath.row].consumerUsername
        cell.textLabel?.text = photo.comments[indexPath.row].consumerComment
        
        return cell
    }
}
