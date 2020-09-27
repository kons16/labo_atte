//
//  ExUIColor.swift
//  ShareTodo
//
//  Created by jun on 2020/09/13.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

public extension UIColor {
    // swiftlint:disable:next cyclomatic_complexity
    static func randomSystemColor() -> UIColor {
        switch Int.random(in: 1 ... 11) {
        case 1: return .systemPink
        case 2: return .systemTeal
        case 3: return .systemRed
        case 4: return .systemFill
        case 5: return .systemGray
        case 6: return .systemGreen
        case 7: return .systemIndigo
        case 8: return .systemBlue
        case 9: return .systemOrange
        case 10: return .systemYellow
        case 11: return .systemPurple
        default: return .black
        }
    }
}
