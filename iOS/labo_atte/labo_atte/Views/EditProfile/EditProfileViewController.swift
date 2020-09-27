//
//  EditProfileViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/07/25.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import CropViewController

final class EditProfileViewController: UIViewController {
    private var presenter: EditProfileViewPresenterProtocol!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var chageProfileButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    var actionSheet = UIAlertController()
    let photoPickerVC = UIImagePickerController()
    
    var profileImage = UIImage()
    var userName: String?
    
    let maxTextfieldLength = 15
    let usersImageViewWide: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationItem()
        self.setupProfileImageView()
        self.setupChageProfileButton()
        self.setupNameTextField()
        self.setupActionSheet()
        self.setupPhotoPickerVC()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.nameTextField.addBorderBottom(borderWidth: 1, color: .systemGray)
    }
    
    deinit {
       NotificationCenter.default.removeObserver(self)
    }
    
    func setupNavigationItem() {
        let stopItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(tapStopEditProfileButton))
        let saveItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(tapSaveEditProfileButton))
        self.navigationItem.leftBarButtonItem = stopItem
        self.navigationItem.rightBarButtonItem = saveItem
        self.navigationItem.leftBarButtonItem?.tintColor = .systemPink
        self.navigationItem.rightBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.title = "Edit Profile"
    }
    
    func setupProfileImageView() {
        self.profileImageView.image = self.profileImage
        self.profileImageView.layer.borderWidth = 0.25
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.layer.masksToBounds = true
    }
    
    func setupChageProfileButton() {
        self.chageProfileButton.setTitle("Chose Profile Photo", for: .normal)
        self.chageProfileButton.titleLabel?.textColor = .systemBlue
        self.chageProfileButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.chageProfileButton.titleLabel?.minimumScaleFactor = 0.4
    }
    
    func setupActionSheet() {
        self.actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.actionSheet.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            self.actionSheet.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width / 2, y: screenSize.size.height, width: 0, height: 0)
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.presenter.didTapTakePhotoAction()
        })
        let selectPhotoAction = UIAlertAction(title: "Select Photo", style: .default, handler: { _ in
            self.presenter.didTapSelectPhotoAction()
        })
        let deletePhotoAction = UIAlertAction(title: "Delete Photo", style: .destructive, handler: { _ in
            self.presenter.didTapDeletePhotoAction()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        self.actionSheet.addAction(takePhotoAction)
        self.actionSheet.addAction(selectPhotoAction)
        self.actionSheet.addAction(deletePhotoAction)
        self.actionSheet.addAction(cancelAction)
    }
    
    func setupPhotoPickerVC() {
        self.photoPickerVC.delegate = self
    }
    
    func setupNameTextField() {
        self.nameTextField.text = userName ?? ""
        self.nameTextField.borderStyle = .none
        self.nameTextField.returnKeyType = .done
        self.nameTextField.delegate = self
        self.nameTextField.enablesReturnKeyAutomatically = true
    }
    
    func setupNotificationCenter() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)),
                                               name: UITextField.textDidChangeNotification, object: self.nameTextField)
    }
    
    @objc func tapStopEditProfileButton() {
        self.presenter.didTapStopEditProfileButton()
    }

    @objc func tapSaveEditProfileButton() {
        guard let userName = self.nameTextField.text else { return }
        guard !userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            self.nameTextField.text = String()
            let stringAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.systemRed.withAlphaComponent(0.5)]
            self.nameTextField.attributedPlaceholder = NSAttributedString(string: "user name", attributes: stringAttributes)
            return
        }
        guard let profileImageData = self.profileImageView.image?.jpegData(compressionQuality: 0.5) else { return }
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.presenter.didTapSaveEditProfileButton(userName: userName, profileImageData: profileImageData)
    }
    
    @IBAction func tapChangeProfileButton(_ sender: Any) {
        self.presenter.didTapChangeProfileButton()
    }
    
    func inject(with presenter: EditProfileViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension EditProfileViewController: EditProfileViewPresenterOutput {
    func dismissEditProfileVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentActionSheet() {
        self.present(self.actionSheet, animated: true, completion: nil)
    }
    
    func showUIImagePickerControllerAsCamera() {
        photoPickerVC.sourceType = .camera
        self.present(photoPickerVC, animated: true, completion: nil)
    }
    
    func showUIImagePickerControllerAsLibrary() {
        photoPickerVC.sourceType = .photoLibrary
        self.present(photoPickerVC, animated: true, completion: nil)
    }
    
    func setDeleteAndSetDefaultImage() {
        DispatchQueue.main.async { self.profileImageView.image = R.image.defaultProfileImage() }
    }
}

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let pickerImage = (info[UIImagePickerController.InfoKey.originalImage] as? UIImage) else { return }
        
        let cropController = CropViewController(croppingStyle: .circular, image: pickerImage)
        cropController.aspectRatioPreset = .presetSquare
        cropController.aspectRatioPickerButtonHidden = true
        cropController.resetAspectRatioEnabled = false
        cropController.rotateButtonsHidden = false
        cropController.cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
        cropController.doneButtonTitle = NSLocalizedString("Done", comment: "")
        cropController.cropView.cropBoxResizeEnabled = false
        cropController.delegate = self

        picker.dismiss(animated: true) {
            self.present(cropController, animated: true, completion: nil)
        }
    }
}

extension EditProfileViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToCircularImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        let resizeImage = image.resizeUIImage(width: self.usersImageViewWide, height: self.usersImageViewWide)
        self.profileImageView.image = resizeImage
        cropViewController.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.nameTextField.resignFirstResponder()
        return true
    }
    
    @objc func textFieldDidChange(notification: NSNotification) {
        guard let textField = notification.object as? UITextField, let text = textField.text else { return }
        if textField.markedTextRange == nil && text.count > maxTextfieldLength {
            textField.text = text.prefix(maxTextfieldLength).description
        }
    }
}
