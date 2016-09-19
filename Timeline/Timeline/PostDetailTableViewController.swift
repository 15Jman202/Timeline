//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var PhotoImageView: UIImageView!
    
    // MARK: - Actions
    
    @IBAction func CommentButtonTapped(sender: AnyObject) {
        presentCommentController()
    }
    
    @IBAction func ShareButtonTapped(sender: AnyObject) {
        presentShareController()
    }
    
    @IBAction func FollowButtonTapped(sender: AnyObject) {
        
    }
    
    // MARK: - View
    
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

    // MARK: - Present View Controllers
    
    func presentCommentController() {
        
        let alertController = UIAlertController(title: "Add a Comment", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Comment Here"
        }
        
        let doneAction = UIAlertAction(title: "Done", style: .Default) { (_) in
            
            guard let comment = alertController.textFields?.first?.text, let post = self.post else { return }
            
            PostController.sharedController.addCommentToPost(comment, post: post)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alertController.addAction(doneAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentShareController() {
        guard let photo = PhotoImageView.image, firstComment = post?.comments.first else { return }
        
        let text = firstComment.text
        let activityController = UIActivityViewController(activityItems: [photo, text], applicationActivities: nil)
        
        presentViewController(activityController, animated: true, completion: nil)
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
