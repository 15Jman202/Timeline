//
//  CreatePostTableViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class CreatePostTableViewController: UITableViewController {
    
    var image: UIImage?
    
    @IBOutlet weak var captionTextField: UITextField!

    @IBAction func CreateButtonTapped(sender: AnyObject) {
        if let image = image,
            let caption = captionTextField.text {
            
            PostController.sharedController.createPost(image, text: caption)
            
        } else {
            
            let alertController = UIAlertController(title: "Missing Post Information", message: "Check your image and caption and try again.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toImagePicker" {
            
            let embedViewController = segue.destinationViewController as? ImageViewController
            embedViewController?.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension CreatePostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelected(image: UIImage) {
        
        self.image = image
    }
}
