//
//  GroupTodoViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct GroupTodoViewBuilder {
    static func create() -> UIViewController {
        guard let groupTodoViewController = GroupTodoViewController.loadFromStoryboard() as? GroupTodoViewController else {
            fatalError("fatal: Failed to initialize the GroupTodoViewController")
        }
        let model = GroupTodoModel()
        let presenter = GroupTodoViewPresenter(model: model)
        groupTodoViewController.inject(with: presenter)
        return groupTodoViewController
    }
}
