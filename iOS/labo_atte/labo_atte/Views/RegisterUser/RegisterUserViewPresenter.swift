//
//  RegisterUserViewPresenter.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation

protocol RegisterUserViewPresenterProtocol {
    var view: RegisterUserViewPresenterOutput! { get set }
    
    func didTapChoseProfileImageButton()
    func didTapTakePhotoAction()
    func didTapSelectPhotoAction()
    func didTapDeletePhotoAction()
    func didTapRegisterButton(userName: String, profileImageData: Data)
}

protocol RegisterUserViewPresenterOutput: class {
    func presentActionSheet()
    func showUIImagePickerControllerAsCamera()
    func showUIImagePickerControllerAsLibrary()
    func setDeleteAndSetDefaultImage()
    func presentMainTabBarController()
}

final class RegisterUserViewPresenter: RegisterUserViewPresenterProtocol, RegisterUserModelOutput {
    weak var view: RegisterUserViewPresenterOutput!
    private var model: RegisterUserModelProtocol
    
    init(model: RegisterUserModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
    
    func didTapChoseProfileImageButton() {
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
    
    func didTapRegisterButton(userName: String, profileImageData: Data) {
        self.model.registerUser(userName: userName, profileImageData: profileImageData)
    }
    
    func successRegisterUser() {
        self.view.presentMainTabBarController()
    }
}
