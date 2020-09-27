//
//  UserRepository.swift
//  ShareTodo
//
//  Created by jun on 2020/09/15.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

class UserRepository: UserRepositoryProtocol {
    private var firestore: Firestore!
    private var listener: ListenerRegistration?
        
    init() {
        self.setUpFirestore()
    }
    
    deinit {
        listener?.remove()
    }
    
    func setUpFirestore() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
}
