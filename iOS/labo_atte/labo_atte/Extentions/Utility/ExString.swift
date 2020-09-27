//
//  ExString.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import Foundation

extension String {
    func removeAt(text: String) -> String? {
        if let range = self.range(of: text) { return self.replacingCharacters(in: range, with: "") }
        return nil
    }
}
