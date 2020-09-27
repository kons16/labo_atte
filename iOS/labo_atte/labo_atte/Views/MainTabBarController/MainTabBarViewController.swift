//
//  MainTabBarViewController.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

import UIKit

final class MainTabBarViewController: UITabBarController {
    private var presenter: MainTabBarViewPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.selectedIndex = 0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
//        let todayTodoVC = TodayTodoViewBuilder.create()
//        let todayTodoNavigationController = UINavigationController(rootViewController: todayTodoVC)
//
//        let groupTodoVC = GroupTodoViewBuilder.create()
//        let groupTodoNavigationController = UINavigationController(rootViewController: groupTodoVC)
//
//        let profileVC = ProfileViewBuilder.create()
//        let profileNavigationController = UINavigationController(rootViewController: profileVC)
//
//        let todayTodoItemImage = UIImage(systemName: "house")
//        let todayTodoItemSelectedImage = UIImage(systemName: "house.fill")
//
//        let groupTodoTabBarItemImage = UIImage(systemName: "checkmark.circle")
//        let groupTodoTabBarItemSelectedImage = UIImage(systemName: "checkmark.circle.fill")
//
//        let profileTabBarItemImage = UIImage(systemName: "person.circle")
//        let profileTabBarItemSelectedImage = UIImage(systemName: "person.circle.fill")
//
//        todayTodoVC.tabBarItem = UITabBarItem(title: "Today", image: todayTodoItemImage, selectedImage: todayTodoItemSelectedImage)
//        groupTodoVC.tabBarItem = UITabBarItem(title: "Group", image: groupTodoTabBarItemImage, selectedImage: groupTodoTabBarItemSelectedImage)
//        profileVC.tabBarItem = UITabBarItem(title: "Me", image: profileTabBarItemImage, selectedImage: profileTabBarItemSelectedImage)
//
//        UITabBar.appearance().tintColor = .systemGreen
        self.viewControllers = [UIViewController(), UIViewController() ]
    }
    
    func inject(with presenter: MainTabBarViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension MainTabBarViewController: MainTabBarViewPresenterOutput {
    
}
