//
//  TodayTodoViewbuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct TodayTodoViewBuilder {
    static func create() -> UIViewController {
        guard let todayTodoViewController = TodayTodoViewController.loadFromStoryboard() as? TodayTodoViewController else {
            fatalError("fatal: Failed to initialize the TodayTodoViewController")
        }
        let model = TodayTodoModel()
        let presenter = TodayTodoViewPresenter(model: model)
        todayTodoViewController.inject(with: presenter)
        return todayTodoViewController
    }
}
