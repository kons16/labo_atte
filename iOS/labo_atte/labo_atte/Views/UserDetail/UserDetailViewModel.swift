//
//  UserDetailViewModel.swift
//  ShareTodo
//
//  Created by jun on 2020/09/23.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation
import Firebase

protocol UserDetailModelProtocol {
    var presenter: UserDetailModelOutput! { get set }
    var group: Group { get set }
    var user: User { get set }
    var todos: [Todo] { get set }
    
    func fetchTodoList()
    func isTheDayAWeekAgo(date: Date) -> Bool
    func getContaintFinishedDate(date: Date) -> Bool
    func calculateForNavigationImage(height: Double) -> (scale: Double, xTranslation: Double, yTranslation: Double)
}

protocol UserDetailModelOutput: class {
    func successFetchTodoList()
}

final class UserDetailModel: UserDetailModelProtocol {
    weak var presenter: UserDetailModelOutput!
    var group: Group
    var user: User
    var todos: [Todo] = Array()
    private var firestore: Firestore!
    private var listener: ListenerRegistration?
    let dateFormatter = DateFormatter()
    
    
    init(group: Group, user: User) {
        self.group = group
        self.user = user
        self.setUpFirestore()
        self.setupDataFormatter()
    }
    
    deinit {
        listener?.remove()
    }
    
    func setUpFirestore() {
        self.firestore = Firestore.firestore()
        let settings = FirestoreSettings()
        self.firestore.settings = settings
    }
    
    func setupDataFormatter() {
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy/MM/dd"
    }
    
    func fetchTodoList() {
        guard let userID = self.user.id else { return }
        guard let groupID = self.group.groupID else { return }
        let collectionRef = "todo/v1/groups/" + groupID + "/todo"
        self.listener = self.firestore.collection(collectionRef).whereField("userID", isEqualTo: userID) .addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let documents = documentSnapshot?.documents else {
                print("The document doesn't exist.")
                return
            }
            
            self.todos = documents.compactMap { queryDocumentSnapshot -> Todo? in
                return try? queryDocumentSnapshot.data(as: Todo.self)
            }
            
            self.presenter.successFetchTodoList()
        }
    }
    
    func isTheDayAWeekAgo(date: Date) -> Bool {
        let aWeekAgo = Date(timeIntervalSinceNow: -60 * 60 * 24 * 7)
        let tomorrow = Date(timeIntervalSinceNow: 60 * 60 * 24)
        return aWeekAgo < date && date < tomorrow
    }
    
    func getTodoListAsFinishedDate() -> [String] {
        return self.todos.filter { $0.isFinished }.reduce([String]()) { list, todo in
            var list = list
            guard todo.isFinished else { return list }
            guard let createdAt = todo.createdAt?.dateValue() else { return list }
            list.append(dateFormatter.string(from: createdAt))
            return list
        }
    }
    
    func getContaintFinishedDate(date: Date) -> Bool {
        let list = getTodoListAsFinishedDate()
        return list.contains(self.dateFormatter.string(from: date))
    }
    
    func calculateForNavigationImage(height: Double) -> (scale: Double, xTranslation: Double, yTranslation: Double) {
        let coeff: Double = {
            let delta = height - Double(NavigationImageConst.NavBarHeightSmallState)
            let heightDifferenceBetweenStates = (NavigationImageConst.NavBarHeightLargeState - NavigationImageConst.NavBarHeightSmallState)
            return delta / Double(heightDifferenceBetweenStates)
        }()

        let factor: Double = Double(NavigationImageConst.ImageSizeForSmallState / NavigationImageConst.ImageSizeForLargeState)

        let scale: Double = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(NavigationImageConst.ImageMaxScale, sizeAddendumFactor + factor)
        }()

        let sizeDiff = Double(NavigationImageConst.ImageSizeForLargeState) * (1.0 - factor)
        let yTranslation: Double = {
            let maxYTranslation = Double(NavigationImageConst.ImageBottomMarginForLargeState - NavigationImageConst.ImageBottomMarginForSmallState) + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Double(NavigationImageConst.ImageBottomMarginForSmallState) + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        return (scale, xTranslation, yTranslation)
    }
}
