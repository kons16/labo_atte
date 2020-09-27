//
//  Todo.swift
//  ShareTodo
//
//  Created by jun on 2020/08/07.
//  Copyright © 2020 jun. All rights reserved.
//

import Firebase

struct Todo: Codable {
    var isFinished: Bool
    let userID: String
    let groupID: String
    @ServerTimestamp var createdAt: Timestamp?
}
