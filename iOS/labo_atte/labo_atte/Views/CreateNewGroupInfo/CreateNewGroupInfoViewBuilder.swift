//
//  CreateNewGroupInfoViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct CreateNewGroupInfoViewBuilder {
    static func create() -> UIViewController {
        guard let createNewGroupInfoViewController = CreateNewGroupInfoViewController.loadFromStoryboard() as? CreateNewGroupInfoViewController else {
            fatalError("fatal: Failed to initialize the CreateNewGroupInfoViewController")
        }
        let model = CreateNewGroupInfoModel()
        let presenter = CreateNewGroupInfoViewPresenter(model: model)
        createNewGroupInfoViewController.inject(with: presenter)
        return createNewGroupInfoViewController
    }
}
