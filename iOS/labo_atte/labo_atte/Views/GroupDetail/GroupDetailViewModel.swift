//
//  GroupDetailViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/09/02.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

protocol GroupDetailModelProtocol {
    var presenter: GroupDetailModelOutput! { get set }
    var group: Group { get set }
    var groupUsers: [User] { get set }
    var isFinishedUsersIDs: [String] { get set }
    
    func fetchTodayTodo()
}

protocol GroupDetailModelOutput: class {
    func successFetchTodayTodo()
}

final class GroupDetailModel: GroupDetailModelProtocol {
    weak var presenter: GroupDetailModelOutput!
    var group: Group
    var groupUsers: [User]
    var isFinishedUsersIDs: [String] = Array()
    private var firestore: Firestore!
    private var listener: ListenerRegistration?
    
    init(group: Group, groupUsers: [User]) {
        self.group = group
        self.groupUsers = groupUsers
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
    
    func fetchTodayTodo() {
        guard let groupID = self.group.groupID else { return }
        let collectionRef = "todo/v1/groups/" + groupID + "/todo"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd"
        
        let startDate: String = formatter.string(from: Date())
        let startTime: Date = formatter.date(from: startDate) ?? Date(timeIntervalSince1970: 0)
        let startTimestamp: Timestamp = Timestamp(date: startTime)
        
        self.listener = self.firestore.collection(collectionRef).whereField("createdAt", isGreaterThanOrEqualTo: startTimestamp).whereField("isFinished", isEqualTo: true).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let documents = documentSnapshot?.documents else {
                print("The document dosent exist.")
                return
            }
            
            let result = documents.compactMap { queryDocumentSnapshot -> Todo? in
                return try? queryDocumentSnapshot.data(as: Todo.self)
            }
                        
            self.isFinishedUsersIDs = result.map { $0.userID }
            self.presenter.successFetchTodayTodo()
        }
    }
    
}
