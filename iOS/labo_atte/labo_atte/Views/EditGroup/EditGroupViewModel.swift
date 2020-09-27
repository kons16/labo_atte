//
//  EditGroupViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/09/09.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation
import Firebase

protocol EditGroupModelProtocol {
    var presenter: EditGroupModelOutput! { get set }
    var group: Group { get set }
    var groupUsers: [User] { get set }
    
    func updateGroup(selectedUsers: [User], groupName: String, groupTask: String, groupImageData: Data)
}

protocol EditGroupModelOutput: class {
    func successSaveGroup()
}

final class EditGroupModel: EditGroupModelProtocol {
    weak var presenter: EditGroupModelOutput!
    var group: Group
    var groupUsers: [User]
    private var firestore: Firestore!
    
    init(group: Group, groupUsers: [User]) {
        self.group = group
        self.groupUsers = groupUsers
        self.setupFirestore()
    }
    
    func setupFirestore() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    func updateGroup(selectedUsers: [User], groupName: String, groupTask: String, groupImageData: Data) {
        let memberIDs = selectedUsers.compactMap { $0.id }
        guard let groupUid = self.group.groupID else { return }
        guard let profileImageURL = self.group.profileImageURL else { return }
        
        let updatedGroup = Group(name: groupName, task: groupTask, members: memberIDs, profileImageURL: profileImageURL)
        let groupData: [String: Any]
        
        let groupReference = self.firestore.collection("todo").document("v1").collection("groups").document(groupUid)
        let batch = self.firestore.batch()
        
        do {
            groupData = try Firestore.Encoder().encode(updatedGroup)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        batch.setData(groupData, forDocument: groupReference, merge: true)
        
        group.members.forEach { memberID in
            batch.setData([:], forDocument: groupReference.collection("members").document(memberID))
        }
        
        batch.commit { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
        }
        
        self.registerGroupImageFireStorage(uid: groupUid, imageData: groupImageData)
    }
    
    func registerGroupImageFireStorage(uid: String, imageData: Data) {
        let storage = Storage.storage()
        let profileImagesRef = storage.reference().child("groupProfileImage/" + uid + ".png")
        
        _ = profileImagesRef.putData(imageData as Data, metadata: nil) { (_, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            profileImagesRef.downloadURL { (url, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                guard let downloadURL = url else { return }
                self.registerProfileURLtoFirestore(uid: uid, downloadURL: downloadURL)
            }
        }
    }
    
    func registerProfileURLtoFirestore(uid: String, downloadURL: URL) {
        let downloadURLStr: String = downloadURL.absoluteString
        
        self.firestore.collection("todo/v1/groups").document(uid).setData(["profileImageURL": downloadURLStr], merge: true) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.presenter.successSaveGroup()
        }
    }
}
