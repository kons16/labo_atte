//
//  EditProfileViewPresenter.swift
//  ShareTodo
//
//  Created by jun on 2020/07/25.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation

protocol EditProfileViewPresenterProtocol {
    var view: EditProfileViewPresenterOutput! { get set }
    
    func didTapStopEditProfileButton()
    func didTapSaveEditProfileButton(userName: String, profileImageData: Data)
    func didTapChangeProfileButton()

    func didTapTakePhotoAction()
    func didTapSelectPhotoAction()
    func didTapDeletePhotoAction()
}

protocol EditProfileViewPresenterOutput: class {
    func dismissEditProfileVC()
    func presentActionSheet()
    func showUIImagePickerControllerAsCamera()
    func showUIImagePickerControllerAsLibrary()
    func setDeleteAndSetDefaultImage()
}

final class EditProfileViewPresenter: EditProfileViewPresenterProtocol, EditProfileModelOutput {
    weak var view: EditProfileViewPresenterOutput!
    private var model: EditProfileModelProtocol
    
    init(model: EditProfileModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
    
    func didTapStopEditProfileButton() {
        self.view.dismissEditProfileVC()
    }
    
    func didTapSaveEditProfileButton(userName: String, profileImageData: Data) {
        self.model.saveUser(userName: userName, profileImageData: profileImageData)
    }
    
    func didTapChangeProfileButton() {
        self.view.presentActionSheet()
    }
    
    func didTapTakePhotoAction() {
        self.view.showUIImagePickerControllerAsCamera()
    }
    
    func didTapSelectPhotoAction() {
        self.view.showUIImagePickerControllerAsLibrary()
    }
    
    func didTapDeletePhotoAction() {
        self.view.setDeleteAndSetDefaultImage()
    }
    
    func successSaveUser() {
        self.view.dismissEditProfileVC()
    }
}
