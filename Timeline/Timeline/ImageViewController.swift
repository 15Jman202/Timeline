//
//  ImageViewController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var Image: UIImageView!
    @IBOutlet weak var ChooseImageButton: UIButton!
    
    @IBAction func Button(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            delegate?.photoSelectViewControllerSelected(image)
            ChooseImageButton.setTitle("", forState: .Normal)
            Image.image = image
        }
    }

    weak var delegate: PhotoSelectViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}


protocol PhotoSelectViewControllerDelegate: class {
    
    func photoSelectViewControllerSelected(image: UIImage)
}

