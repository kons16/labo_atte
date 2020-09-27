//
//  CreateNewGroupViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

protocol CreateNewGroupModelProtocol {
    var presenter: CreateNewGroupModelOutput! { get set }
    var selectedUsersArray: [User] { get set }
    var searchedUsersArray: [User] { get set }
    
    func isContaintsUser(user: User) -> Bool
    func searchUser(searchText: String)
    func removeSelectedUserFromSelectedUserArray(user: User)
    func appendUserToSelectedUserArray(user: User)
    func removeSelectedUsersArray(index: Int) -> [User]
}

protocol CreateNewGroupModelOutput: class {
    func successRemoveSelectedUser()
    func successAppendUser()
    
    func successSearchUser()
}

final class CreateNewGroupModel: CreateNewGroupModelProtocol {
    weak var presenter: CreateNewGroupModelOutput!
    private var firestore: Firestore!
    var selectedUsersArray: [User] = Array()
    var searchedUsersArray: [User] = Array()
    
    init() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    func removeSelfUidFromSearchedUsersArray(removeUid: String, array: [User]) -> [User] {
        return array.filter { ($0.id ?? "") != removeUid }
    }
    
    /// ユーザをFirestoreから検索する関数
    /// - Parameter searchText: 検索するユーザ名
    func searchUser(searchText: String) {
        self.firestore.collection("todo/v1/users").whereField("name", isEqualTo: searchText).getDocuments { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = documentSnapshot?.documents else {
                print("The document doesn't exist.")
                return
            }
            
            let searchedUsers = documents.compactMap { queryDocumentSnapshot -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            self.searchedUsersArray = searchedUsers
            self.searchedUsersArray = self.removeSelfUidFromSearchedUsersArray(removeUid: uid, array: self.searchedUsersArray)
            self.presenter.successSearchUser()
        }
    }
    
    /// ユーザが既に選択されているかを返す
    /// - Parameter user: 検索するユーザ
    /// - Returns: 検索結果
    func isContaintsUser(user: User) -> Bool {
        if self.selectedUsersArray.filter({ $0.id == user.id ?? "" }).isEmpty { return false }
        return true
    }
    
    func removeSelectedUserFromSelectedUserArray(user: User) {
        self.selectedUsersArray = self.selectedUsersArray.filter({ $0.id != user.id })
        
        self.presenter.successRemoveSelectedUser()
    }
    
    func appendUserToSelectedUserArray(user: User) {
        self.selectedUsersArray.append(user)
        self.presenter.successAppendUser()
    }
    
    /// `selectedUsersArray`からあるインデックスを削除する
    /// - Parameter index: 削除する配列番号
    /// - Returns: 削除した後の`selectedUsersArray`
    func removeSelectedUsersArray(index: Int) -> [User] {
        self.selectedUsersArray.remove(at: index)
        return self.selectedUsersArray
    }
}
