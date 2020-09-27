//
//  CreateNewGroupViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct CreateNewGroupViewBuilder {
    static func create() -> UIViewController {
        guard let createNewGroupViewController = CreateNewGroupViewController.loadFromStoryboard() as? CreateNewGroupViewController else {
            fatalError("fatal: Failed to initialize the CreateNewGroupViewController")
        }
        let model = CreateNewGroupModel()
        let presenter = CreateNewGroupViewPresenter(model: model)
        createNewGroupViewController.inject(with: presenter)
        return createNewGroupViewController
    }
}
