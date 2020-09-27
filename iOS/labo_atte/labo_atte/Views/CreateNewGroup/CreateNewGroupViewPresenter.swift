//
//  CreateNewGroupViewPresenter.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

protocol CreateNewGroupViewPresenterProtocol {
    var view: CreateNewGroupViewPresenterOutput! { get set }
    var numberOfSearchedUsers: Int { get }
    var numberOfSelectedUsers: Int { get }
    var searchedUsers: [User] { get }
    var selectedUsers: [User] { get }
    
    func isSelected(user: User) -> Bool
    
    func didSelectedSerchUserTableview(selectedUser: User)
    func didTapSelectedUserCollectionViewCellDeleteUserButton(index: Int)
    
    func didTapStopCreateRoomButton()
    func didTapCreateRoomutton()
    
    func didSearchBarSearchButtonClicked(searchText: String)
}

protocol CreateNewGroupViewPresenterOutput: class {
    func reloadSerchUserTableview()
    func reloadSelectedUserCollectionView()
    
    func hiddenSelectedUsersCollectionView()
    func dismissCreateChatRoomVC()
    func clearSearchUserTableView()
    
    func startActivityIndicator()
    func stopActivityIndicator()
    
    func presentCreateNewGropuInfoVC()
}

final class CreateNewGroupViewPresenter: CreateNewGroupViewPresenterProtocol, CreateNewGroupModelOutput {
    weak var view: CreateNewGroupViewPresenterOutput!
    private var model: CreateNewGroupModelProtocol
    
    var numberOfSearchedUsers: Int {
        return self.model.searchedUsersArray.count
    }
    
    var numberOfSelectedUsers: Int {
        return model.selectedUsersArray.count
    }
    
    var searchedUsers: [User] {
        return model.searchedUsersArray
    }
    
    var selectedUsers: [User] {
        return model.selectedUsersArray
    }
    
    init(model: CreateNewGroupModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
    
    func didSelectedSerchUserTableview(selectedUser: User) {
        if self.model.isContaintsUser(user: selectedUser) {
            self.model.removeSelectedUserFromSelectedUserArray(user: selectedUser)
            return
        }
        self.model.appendUserToSelectedUserArray(user: selectedUser)
    }
    
    func didTapSelectedUserCollectionViewCellDeleteUserButton(index: Int) {
        let updatedSelectedUsersArray = self.model.removeSelectedUsersArray(index: index)
        
        self.view.reloadSelectedUserCollectionView()
        self.view.reloadSerchUserTableview()
        if updatedSelectedUsersArray.isEmpty { self.view.hiddenSelectedUsersCollectionView()}
    }
    
    func didTapStopCreateRoomButton() {
        self.view.dismissCreateChatRoomVC()
    }
    
    func didTapCreateRoomutton() {
        guard !self.selectedUsers.isEmpty else { return }
        
        self.view.presentCreateNewGropuInfoVC()
    }
    
    func didSearchBarSearchButtonClicked(searchText: String) {
        self.view.clearSearchUserTableView()
        self.view.startActivityIndicator()
        self.model.searchUser(searchText: searchText)
    }
    
    func isSelected(user: User) -> Bool { return self.selectedUsers.firstIndex { user.id == $0.id } != nil }
    
    func successSearchUser() {
        self.view.reloadSerchUserTableview()
        self.view.stopActivityIndicator()
    }
    
    func successRemoveSelectedUser() {
        self.view.reloadSelectedUserCollectionView()
        self.view.reloadSerchUserTableview()
        if self.selectedUsers.isEmpty { self.view.hiddenSelectedUsersCollectionView()}
    }
    
    func successAppendUser() {
        self.view.reloadSelectedUserCollectionView()
        self.view.reloadSerchUserTableview()
    }
}
