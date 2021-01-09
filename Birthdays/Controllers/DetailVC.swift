//
//  NewItemVC.swift
//  Birthdays
//
//  Created by user on 05.01.2021.
//  Copyright © 2021 user. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet var image: UIImageView!
    @IBOutlet var nameTF: UITextField!
    @IBOutlet var birthdayDP: UIDatePicker!
    @IBOutlet var addButton: UIButton!
    
    var exImage: UIImage?
    var exName: String?
    var exBirthday: Date?
    
    var imagePicker = UIImagePickerController()
    var pickImageCallback : ((UIImage) -> Void)?
    
    public var completion: ((String, Date, UIImage?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        image.image = exImage ?? UIImage(systemName: "person.crop.circle.fill")
        nameTF.text = exName ?? nil
        birthdayDP.date = exBirthday ?? Date()
        image.layer.cornerRadius = image.layer.frame.height / 2
        addButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
            self.pickImageCallback = { choosingImage in
                self.image.image = choosingImage
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError()
        }
        pickImageCallback?(image)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton){
        if let name = nameTF.text, !name.isEmpty{
            let birthday = birthdayDP.date
            completion?(name, birthday, image.image)
        }
    }
}

extension DetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
}
