//
//  RegisterUserViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct RegisterUserViewBuilder {
    static func create() -> UIViewController {
        guard let registerUserViewController = RegisterUserViewController.loadFromStoryboard() as? RegisterUserViewController else {
            fatalError("fatal: Failed to initialize the RegisterUserViewController")
        }
        let model = RegisterUserModel()
        let presenter = RegisterUserViewPresenter(model: model)
        registerUserViewController.inject(with: presenter)
        return registerUserViewController
    }
}
