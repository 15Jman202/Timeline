//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var PhotoImageView: UIImageView!
    
    // MARK: Actions
    
    @IBAction func CommentButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func ShareButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func FollowButtonTapped(sender: AnyObject) {
        
    }
    
    var post: Post? {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else { return 0 }
            return post.comments.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        guard let post = post else { return cell }
        
        cell.detailTextLabel?.text = "\(post.comments[indexPath.row])"
        PhotoImageView.image = post.photo
        
        return cell
    }
}
