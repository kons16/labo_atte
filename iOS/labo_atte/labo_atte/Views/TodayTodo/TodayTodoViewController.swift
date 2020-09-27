//
//  TodayTodoViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

final class TodayTodoViewController: UIViewController {
    private var presenter: TodayTodoViewPresenterProtocol!
    @IBOutlet weak var todayTodoCollectionView: UICollectionView!
    
    var activityIndicator = UIActivityIndicatorView()
    
    private let todayTodoCollectionViewCellId = "TodayTodoCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupNavigationBar()
        self.setupTodayTodoCollectionView()
        self.setupActivityIndicator()
        
        self.presenter.didViewDidLoad()
    }
    
    func setupView() {
        self.view.backgroundColor = .secondarySystemBackground
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Today"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupTodayTodoCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 95)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 16
        flowLayout.sectionInset = UIEdgeInsets(top: 32, left: 16, bottom: 40, right: 16)
        
        self.todayTodoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
        self.todayTodoCollectionView.backgroundColor = .secondarySystemBackground
        self.todayTodoCollectionView.alwaysBounceVertical = true
        
        self.todayTodoCollectionView.delegate = self
        self.todayTodoCollectionView.dataSource = self
        self.todayTodoCollectionView.emptyDataSetSource = self
        self.todayTodoCollectionView.emptyDataSetDelegate = self
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    func inject(with presenter: TodayTodoViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension TodayTodoViewController: TodayTodoViewPresenterOutput {
    func reloadTodayTodoCollectionView() {
        DispatchQueue.main.async { self.todayTodoCollectionView.reloadData() }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
    }
    
    func showRequestAllowNotificationView() {
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard granted == true else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}

extension TodayTodoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.presenter.numberOfGroups
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: todayTodoCollectionViewCellId, for: indexPath) as! TodayTodoCollectionViewCell
        cell.configure(with: self.presenter.groups[indexPath.item], isFinished: self.presenter.isFinishedTodo(index: indexPath.item))
        cell.radioButtonAction = { [weak self] in
            guard let self = self else { return }
            self.presenter.didTapRadioButton(index: indexPath.item)
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

}

extension TodayTodoViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Task"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
   
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "It will be displayed when you create New Group!"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
