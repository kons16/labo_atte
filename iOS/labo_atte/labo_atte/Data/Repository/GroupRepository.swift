//
//  GroupRepository.swift
//  ShareTodo
//
//  Created by jun on 2020/09/15.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

class GroupRepository: GroupRepositoryProtocol {
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
    
    func fetchGroup(groupID: String) {
        let documentRef = "todo/v1/groups/" + groupID
        
        self.listener = self.firestore.document(documentRef).addSnapshotListener { (document, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("The document doesn't exist.")
                return
            }
            
            do {
                let groupData = try document.data(as: Group.self)
                guard let group = groupData else { return }
           
                GroupDataStore.groupDataStore.append(group: group)
            } catch let error {
                print("Error happen.")
            }
        }
    }
}
