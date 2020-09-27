//
//  TodayTodoViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

protocol TodayTodoModelProtocol {
    var presenter: TodayTodoModelOutput! { get set }
    var groups: [Group] { get set }
    var todos: [Todo] { get set }
    
    func fetchGroups()
    func fetchTodayTodo(groupDocuments: [QueryDocumentSnapshot], userID: String)
    
    func isFirstOpen() -> Bool
    func isFinishedTodo(index: Int) -> Bool
    
    func unfinishedTodo(index: Int)
    func finishedTodo(index: Int)
}

protocol TodayTodoModelOutput: class {
    func successFetchTodayTodo()
    func successUnfinishedTodo()
    func successFinishedTodo()
}

final class TodayTodoModel: TodayTodoModelProtocol {
    weak var presenter: TodayTodoModelOutput!
    var groups: [Group] = Array()
    var todos: [Todo] = Array()
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
        //self.firestore.settings = settings
    }
    
    func fetchGroups() {
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
            
            self.groups = documents.compactMap { queryDocumentSnapshot -> Group? in
                return try? queryDocumentSnapshot.data(as: Group.self)
            }
            
            self.todos.removeAll()
            self.fetchTodayTodo(groupDocuments: documents, userID: user.uid)
        }
    }
    
    func getTodayFormat() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy_MM_dd"
        return formatter.string(from: Date())
    }
    
    func fetchTodayTodo(groupDocuments: [QueryDocumentSnapshot], userID: String) {
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        let todayFormat = getTodayFormat()
        
        for document in groupDocuments {
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) { [weak self] in
                guard let self = self else { return }
                
                let documentRef = "todo/v1/groups/" + document.documentID + "/todo/" + userID + "_" + todayFormat
                print(documentRef)
                self.firestore.document(documentRef).getDocument { (document, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        dispatchGroup.leave()
                        return
                    }
                    
                    guard let document = document, document.exists else {
                        print("The document doesn't exist.")
                        dispatchGroup.leave()
                        return
                    }
                    
                    do {
                        let todoData = try document.data(as: Todo.self)
                        guard let todo = todoData else { return }
                        self.todos.append(todo)
                    } catch {
                        print("Error happen.")
                    }
                    
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.presenter.successFetchTodayTodo()
        }
    }
    
    func isContainsTodoInGroups(index: Int) -> Bool {
        let group = groups[index]
        return !self.todos.filter({ $0.groupID == group.groupID ?? ""}).isEmpty
    }
    
    func isFinishedTodo(index: Int) -> Bool {
        guard isContainsTodoInGroups(index: index) else { return false }
        let todo = todos.filter({ $0.groupID == groups[index].groupID ?? ""}).first
        
        if let todo = todo {
            return todo.isAttended
        } else {
            return false
        }
    }
    
    func getFinishedTodoIndex(groupIndex: Int) -> Int? {
        for tmp in 0 ..< todos.count {
            if self.todos[tmp].groupID == self.groups[groupIndex].groupID ?? "" { return tmp }
        }
        return nil
    }
    
    func unfinishedTodo(index: Int) {
        let todo = todos.filter({ $0.groupID == groups[index].groupID ?? ""}).first
        guard var finishedTodo = todo else { return }
        guard let finishedTodoIndex = getFinishedTodoIndex(groupIndex: index) else { return }
        
        finishedTodo.isAttended = false
        let todayFormat = getTodayFormat()
        
        let documentRef = "todo/v1/groups/" + finishedTodo.groupID + "/todo/" + finishedTodo.userID + "_" + todayFormat
        
        do {
            _ = try self.firestore.document(documentRef).setData(from: finishedTodo, merge: true) { [weak self] error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                self?.todos[finishedTodoIndex].isAttended = false
                self?.presenter.successUnfinishedTodo()
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    func finishedTodo(index: Int) {
        guard let user = Auth.auth().currentUser else { return }
        guard let groupID = self.groups[index].groupID else { return }
        let todayFormat = getTodayFormat()
        let documentRef = "todo/v1/groups/" + groupID + "/todo/" + user.uid + "_" + todayFormat
        let todo = Todo(isAttended: true, isTodayAttended: true, userID: user.uid, groupID: groupID)
        
        do {
            _ = try self.firestore.document(documentRef).setData(from: todo, merge: true) { [weak self] error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                self?.presenter.successFinishedTodo()
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
            return
        }
    }
    
    func isFirstOpen() -> Bool {
        //TODO:- 実装後に以下の一文を取り除くこと
        return true
        UserDefaults.standard.register(defaults: ["isFirstOpen": true])
        if !UserDefaults.standard.bool(forKey: "isFirstOpen") { return false }
        
        UserDefaults.standard.set(false, forKey: "isFirstOpen")
        return true
    }
}
