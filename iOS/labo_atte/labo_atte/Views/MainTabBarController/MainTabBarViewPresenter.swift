//
//  MainTabBarViewPresenter.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

protocol MainTabBarViewPresenterProtocol {
    var view: MainTabBarViewPresenterOutput! { get set }
}

protocol MainTabBarViewPresenterOutput: class {
    
}

final class MainTabBarViewPresenter: MainTabBarViewPresenterProtocol, MainTabBarModelOutput {
    weak var view: MainTabBarViewPresenterOutput!
    private var model: MainTabBarModelProtocol
    
    init(model: MainTabBarModelProtocol) {
        self.model = model
        self.model.presenter = self
    }
}
