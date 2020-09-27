//
//  User.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

struct User: Codable, Equatable {
    @DocumentID var id: String?
    let name: String
    let profileImageURL: String?
}
