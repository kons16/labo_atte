//
//  GroupTodoViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

protocol GroupTodoModelProtocol {
    var presenter: GroupTodoModelOutput! { get set }
    var group: [Group] { get set }
    var groupUsers: [[User]] { get set }
    
    func fetchGroup()
    func fetchGroupsUsersNames()
}

protocol GroupTodoModelOutput: class {
    func successFetchGroup()
    func successFetchUsersName()
}

final class GroupTodoModel: GroupTodoModelProtocol {
    weak var presenter: GroupTodoModelOutput!
    var group: [Group] = Array()
    var groupUsers: [[User]] = Array()
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
    
    func fetchGroup() {
        guard let user = Auth.auth().currentUser else { return }
        
        self.listener = self.firestore.collection("todo/v1/groups/").whereField("members", arrayContains: user.uid).addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = documentSnapshot?.documents else {
                print("The document doesn't exist.")
                return
            }
            
            self.group = documents.compactMap { queryDocumentSnapshot -> Group? in
                return try? queryDocumentSnapshot.data(as: Group.self)
            }
            
            self.presenter.successFetchGroup()
        }
    }
    
    func fetchUsersNames(membersIDs: [String]) -> [User] {
        var result: [User] = Array()
        let semaphore = DispatchSemaphore(value: 0)
        
        for membersID in membersIDs {
            let usersPath = "todo/v1/users/" + membersID
            self.firestore.document(usersPath).getDocument { (document, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    semaphore.signal()
                    return
                }
                
                guard let document = document, document.exists else {
                    print("The document doesn't exist.")
                    semaphore.signal()
                    return
                }
                
                do {
                    let userData = try document.data(as: User.self)
                    guard let user = userData else { return }
                    result.append(user)
                } catch {
                    print("Error happen")
                }
                
                semaphore.signal()
            }
        }
        
        for _ in 1 ... membersIDs.count { semaphore.wait() }
        
        return result
    }
    
    func fetchGroupsUsersNames() {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        for group in self.group {
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) { [weak self] in
                guard let self = self else { return }
                let result = self.fetchUsersNames(membersIDs: group.members)
                //排他的に制御する必要がある
                DispatchQueue.main.async {
                    self.groupUsers.append(result)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.groupUsers = self.sortGroupUsersArray(groupArray: self.group, groupUsersArray: self.groupUsers)
            self.presenter.successFetchUsersName()
        }
    }
    
    func sortGroupUsersArray(groupArray: [Group], groupUsersArray: [[User]]) -> [[User]] {
        var result = groupUsersArray
        
        for (groupNum, group) in groupArray.enumerated() {
            for (usersNum, users) in result.enumerated() {
                let usersIDs = users.reduce([]) { (array, user) -> [String] in
                    var array = array
                    array.append(user.id ?? "")
                    return array
                }
                
                if group.members.sorted() == usersIDs.sorted() {
                    result.swapAt(groupNum, usersNum)
                }
            }
        }
        
        return result
    }
}
