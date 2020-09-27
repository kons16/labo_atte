//
//  TodayTodoViewPresenter.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

protocol TodayTodoViewPresenterProtocol {
    var view: TodayTodoViewPresenterOutput! { get set }
    var numberOfGroups: Int { get }
    var groups: [Group] { get }
    var todos: [Todo] { get }
    
    func didViewDidLoad()
    func didTapRadioButton(index: Int)
    
    func isFinishedTodo(index: Int) -> Bool
}

protocol TodayTodoViewPresenterOutput: class {
    func reloadTodayTodoCollectionView()
    func showRequestAllowNotificationView()
    
    func startActivityIndicator()
    func stopActivityIndicator()
}

final class TodayTodoViewPresenter: TodayTodoViewPresenterProtocol, TodayTodoModelOutput {
    weak var view: TodayTodoViewPresenterOutput!
    private var model: TodayTodoModelProtocol
    
    var numberOfGroups: Int {
        return self.model.groups.count
    }
    
    var groups: [Group] {
        return self.model.groups
    }
    
    var todos: [Todo] {
        return self.model.todos
    }
    
    init(model: TodayTodoModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
    
    func didViewDidLoad() {
        if self.model.isFirstOpen() { self.view.showRequestAllowNotificationView() }
        self.view.startActivityIndicator()
        self.model.fetchGroups()
    }
    
    func successFetchTodayTodo() {
        self.view.reloadTodayTodoCollectionView()
        self.view.stopActivityIndicator()
    }
    
    func successUnfinishedTodo() {
        self.view.reloadTodayTodoCollectionView()
    }
    
    func successFinishedTodo() {
        self.model.fetchGroups()
        self.view.stopActivityIndicator()
    }
    
    func didTapRadioButton(index: Int) {
        if self.model.isFinishedTodo(index: index) {
            self.model.unfinishedTodo(index: index)
            return
        }
        
        self.model.finishedTodo(index: index)
    }
    
    func isFinishedTodo(index: Int) -> Bool {
        return self.model.isFinishedTodo(index: index)
    }
}
