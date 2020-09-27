//
//  EditGroupViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/09/09.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct EditGroupViewBuilder {
    static func create(group: Group, groupUsers: [User]) -> UIViewController {
        guard let editGroupViewController = EditGroupViewController.loadFromStoryboard() as? EditGroupViewController else {
            fatalError("fatal: Failed to initialize the EditGroupViewController")
        }
        let model = EditGroupModel(group: group, groupUsers: groupUsers)
        let presenter = EditGroupViewPresenter(model: model)
        editGroupViewController.inject(with: presenter)
        return editGroupViewController
    }
}
