//
//  CreateNewGroupInfoViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation
import Firebase

protocol CreateNewGroupInfoModelProtocol {
    var presenter: CreateNewGroupInfoModelOutput! { get set }
    
    func fetchUser()
    func createGroup(selectedUsers: [User], groupName: String, groupTask: String, groupImageData: Data)
}

protocol CreateNewGroupInfoModelOutput: class {
    func successCreateGroup()
    func successFetchUser(user: User)
}

final class CreateNewGroupInfoModel: CreateNewGroupInfoModelProtocol {
    weak var presenter: CreateNewGroupInfoModelOutput!
    private var firestore: Firestore!
    
    init() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    func fetchUser() {
        guard let user = Auth.auth().currentUser else { return }
        self.firestore.collection("todo/v1/users/").document(user.uid).addSnapshotListener { [weak self] (document, error) in
            guard let self = self else { return }
            
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
                self.presenter.successFetchUser(user: userInfo!)
            } catch let error {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func createGroup(selectedUsers: [User], groupName: String, groupTask: String, groupImageData: Data) {
        let memberIDs = selectedUsers.compactMap { $0.id }
        let groupUid: String = UUID().uuidString
        
        let group = Group(name: groupName, task: groupTask, members: memberIDs, profileImageURL: nil)
        let groupData: [String: Any]
        
        let groupReference = self.firestore.collection("todo").document("v1").collection("groups").document(groupUid)
        let batch = self.firestore.batch()
        
        do {
            groupData = try Firestore.Encoder().encode(group)
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        batch.setData(groupData, forDocument: groupReference)
        
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
            
            self.presenter.successCreateGroup()
        }
    }
}
