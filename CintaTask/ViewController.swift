//
//  ViewController.swift
//  CintaTask
//
//  Created by $umit on 06/07/22.
//

import UIKit
import QCropper

class ViewController: UIViewController {
    
    @IBOutlet weak var CapturedImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onClickSkip(_ sender: Any) {
        self.CapturedImage.image = nil
    }
    @IBAction func onClickSave(_ sender: Any) {
        guard let selectedImage = self.CapturedImage.image else {
            showAlertMessage(vc: self, title: "Click Image", message: "", actionTitle: "Ok", handler: nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            showAlertMessage(vc: self, title: "Save error", message: error.localizedDescription, actionTitle: "Ok", handler: nil)
        } else {
            showAlertMessage(vc: self, title: "Your image has been saved to your photos.", message: "", actionTitle: "Ok", handler: nil)
        }
    }
    
    @IBAction func onClickCamera(_ sender: Any) {
        let actionCtrl = UIAlertController(title: "Select a option", message: nil, preferredStyle:(UIDevice.current.userInterfaceIdiom == .phone) ? .actionSheet : .alert)
        let actionCamera = UIAlertAction(title: "Take a Photo", style: .default) {(action) in
            self.openImageController(isFromCamera: true)
        }
        let actionLibrary = UIAlertAction(title: "Choose from Library", style: .default) { (action) in
            self.openImageController(isFromCamera: false)
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionCtrl.addAction(actionCamera)
        actionCtrl.addAction(actionLibrary)
        actionCtrl.addAction(actionCancel)
        present(actionCtrl, animated: true, completion: nil)
    }
    func openImageController(isFromCamera:Bool)  {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (isFromCamera) {
            picker.sourceType = UIImagePickerController.SourceType.camera
        } else {
            picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        picker.view.backgroundColor = .black
        present(picker, animated: true, completion:nil)
    }
    func showAlertMessage(vc: UIViewController, title: String?, message: String?, actionTitle: String?, handler:((UIAlertAction)->Void)?) -> Void {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let alertAction = UIAlertAction(title: actionTitle, style: .cancel, handler: handler)
        
        alertCtrl.addAction(alertAction)
        vc.present(alertCtrl, animated: true, completion: nil)
    }
}

// MARK: - Image Picker Delegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(image)
            let cropper = CropperViewController(originalImage: image)
            cropper.delegate = self
            picker.dismiss(animated: true) {
                self.present(cropper, animated: true, completion: nil)
            }
        }else if let image = info[UIImagePickerController.InfoKey.mediaMetadata] as? UIImage {
            let cropper = CropperViewController(originalImage: image)
            cropper.delegate = self
            picker.dismiss(animated: true) {
                self.present(cropper, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

// MARK: - Croper Delegate
extension ViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true, completion: nil)
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            self.CapturedImage.image = image
        } else {
            print("Something went wrong")
        }
    }
}

