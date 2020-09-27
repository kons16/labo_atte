//
//  ProfileViewPresenter.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation

protocol ProfileViewPresenterProtocol {
    var view: ProfileViewPresenterOutput! { get set }
    
    func didTapEditProfileButton()
    func didViewDidLoad()
}

protocol ProfileViewPresenterOutput: class {
    func presentEditProfileVC()
    func setUserName(userName: String)
    func setProfileImage(URL: URL)
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol, ProfileModelOutput {
    weak var view: ProfileViewPresenterOutput!
    private var model: ProfileModelProtocol
    
    init(model: ProfileModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
    
    func didTapEditProfileButton() {
        self.view.presentEditProfileVC()
    }
    
    func didViewDidLoad() {
        self.model.fetchUser()
    }
    
    func successFetchUser(user: User) {
        self.view.setUserName(userName: user.name)
        guard let url = URL(string: user.profileImageURL ?? "") else { return }
        self.view.setProfileImage(URL: url)
    }
}
