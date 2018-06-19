//
//  ViewController+UIImagePickerControllerDelegate.swift
//  Gravity
//
//  Created by Alexander Pagliaro on 6/9/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MobileCoreServices

extension ViewController: UIImagePickerControllerDelegate {
    func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        DispatchQueue.main.async {
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        guard let mediaType = info[UIImagePickerControllerMediaType] as? String else { return }
        var object = self.state.currentObject
        if mediaType == kUTTypeImage as String {
            object.identifier = UUID()
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            guard let mediaURL = object.mediaURL else { return }
            do {
                try UIImageJPEGRepresentation(image, 1.0)?.write(to: mediaURL)
                object.type = .media(.image)
                self.state.currentObject = object
                loadObjectMedia()
            } catch {
                print(error)
            }
        }
    }
}
