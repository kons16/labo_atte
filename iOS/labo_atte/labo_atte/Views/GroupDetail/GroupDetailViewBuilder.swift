//
//  GroupDetailViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/09/02.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct GroupDetailViewBuilder {
    static func create(group: Group, groupUsers: [User]) -> UIViewController {
        guard let groupDetailViewController = GroupDetailViewController.loadFromStoryboard() as? GroupDetailViewController else {
            fatalError("fatal: Failed to initialize the GroupDetailViewController")
        }
        let model = GroupDetailModel(group: group, groupUsers: groupUsers)
        let presenter = GroupDetailViewPresenter(model: model)
        groupDetailViewController.inject(with: presenter)
        return groupDetailViewController
    }
}
