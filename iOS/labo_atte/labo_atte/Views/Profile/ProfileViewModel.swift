//
//  ProfileViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

protocol ProfileModelProtocol {
    var presenter: ProfileModelOutput! { get set }
    
    func fetchUser()
}

protocol ProfileModelOutput: class {
    func successFetchUser(user: User)
}

final class ProfileModel: ProfileModelProtocol {
    weak var presenter: ProfileModelOutput!
    private var firestore: Firestore!
    private var listener: ListenerRegistration?
    
    init() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchUser() {
        guard let user = Auth.auth().currentUser else { return }
        self.listener = self.firestore.collection("todo/v1/users/").document(user.uid).addSnapshotListener { [weak self] (document, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let document = document else {
                print("The document doesn't exist.")
                return
            }
            
            do {
                let userInfo = try document.data(as: User.self)
                self?.presenter.successFetchUser(user: userInfo!)
            } catch let error {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
}
