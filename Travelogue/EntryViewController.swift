//
//  EntryViewController.swift
//  Travelogue
//
//  Created by Dylan Mouser on 5/10/19.
//  Copyright © 2019 Dylan Mouser. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    let dateFormatter = DateFormatter()
    let newEntryDateFormatter = DateFormatter()
    let imagePickerController = UIImagePickerController()
    
    var entry: Entry?
    var trip: Trip?
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        newEntryDateFormatter.dateStyle = .medium
        
        if let entry = entry {
            titleTextField.text = entry.title
            bodyTextView.text = entry.body
            if let addDate = entry.addDate {
                dateLabel.text = dateFormatter.string(from: addDate)
            }
            image = entry.image
            imageView.image = image
        } else {
            titleTextField.text = ""
            bodyTextView.text = ""
            dateLabel.text = newEntryDateFormatter.string(from: Date(timeIntervalSinceNow: 0))
            imageView.image = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        selectImageSource()
    }
    
    func selectImageSource() {
        let alert = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (alertAction) in
            self.takePhotoUsingCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            (alertAction) in
            self.selectPhotoFromLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func takePhotoUsingCamera() {
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
            alertNotifyUser(message: "This device has no camera.")
            return
        }
        
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func selectPhotoFromLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image = selectedImage
        imageView.image = image
        if let entry = entry {
            entry.image = selectedImage
        }
    }
    
    @IBAction func save(_ sender: Any) {
        guard let title = titleTextField.text?.trimmingCharacters(in: .whitespaces), !title.isEmpty else {
            alertNotifyUser(message: "Please enter a title before saving the entry.")
            return
        }
        
        if let entry = entry {
            if let trip = trip {
                entry.title = title
                entry.body = bodyTextView.text
                entry.image = image
                entry.trip = trip
            }
        } else {
            if let trip = trip {
                entry = Entry(title: title, body: bodyTextView.text, image: image, trip: trip)
            }
        }
        
        if let entry = entry {
            do {
                let managedContext = entry.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "The entry could not be saved.")
            }
            
        } else {
            alertNotifyUser(message: "The entry could not be created.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func titleChanged(_ sender: Any) {
        title = titleTextField.text
    }
    
    
}
