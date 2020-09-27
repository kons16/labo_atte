//
//  MainTabBarViewModel.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

protocol MainTabBarModelProtocol {
    var presenter: MainTabBarModelOutput! { get set }
}

protocol MainTabBarModelOutput: class {
    
}

final class MainTabBarModel: MainTabBarModelProtocol {
    weak var presenter: MainTabBarModelOutput!
}
