//
//  EditProfileViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/25.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation
import Firebase

protocol EditProfileModelProtocol {
    var presenter: EditProfileModelOutput! { get set }
    
    func saveUser(userName: String, profileImageData: Data)
}

protocol EditProfileModelOutput: class {
    func successSaveUser()
}

final class EditProfileModel: EditProfileModelProtocol {
    weak var presenter: EditProfileModelOutput!
    private var firestore: Firestore!
    
    init() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    func saveUser(userName: String, profileImageData: Data) {
        guard let user = Auth.auth().currentUser else { return }
        
        self.saveUserFirebase(uid: user.uid, name: userName)
        self.saveUserImageFireStorage(uid: user.uid, imageData: profileImageData)
    }
    
    func saveUserFirebase(uid: String, name: String) {
        self.firestore.collection("todo/v1/users/").document(uid).updateData(["name": name]) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
        }
    }
    
    func saveUserImageFireStorage(uid: String, imageData: Data) {
        let storage = Storage.storage()
        let profileImagesRef = storage.reference().child("userProfileImage/" + uid + ".png")
        
        _ = profileImagesRef.putData(imageData as Data, metadata: nil) { (metadata, error) in
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
                self.saveProfileURLtoFirestore(uid: uid, downloadURL: downloadURL)
            }
        }
    }
    
    func saveProfileURLtoFirestore(uid: String, downloadURL: URL) {
        let downloadURLStr: String = downloadURL.absoluteString
        
        self.firestore.collection("todo/v1/users").document(uid).updateData(["profileImageURL": downloadURLStr]) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            self.presenter.successSaveUser()
        }
    }
}
