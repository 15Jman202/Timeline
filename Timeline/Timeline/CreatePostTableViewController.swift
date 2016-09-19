//
//  CreatePostTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class CreatePostTableViewController: UITableViewController {
    
    var post: Post?
    
    var image: UIImage?
    
    // MARK: - Outlets
    
    @IBOutlet weak var captionTextField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func createButtonTapped() {
        if let image = image,
            let caption = captionTextField.text {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                PostController.sharedController.createPost(image, text: caption, completion: nil)
            })
            
        } else {
            
            let alertController = UIAlertController(title: "Missing Post Information", message: "Check your image and caption and try again.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toImagePicker" {
            
            let embedViewController = segue.destinationViewController as? ImageViewController
            embedViewController?.delegate = self
        }
    
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Extension
}

extension CreatePostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(image: UIImage) {
        
        self.image = image
    }
}
