//
//  GroupTodoViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import DZNEmptyDataSet

final class GroupTodoViewController: UIViewController {
    private var presenter: GroupTodoViewPresenterProtocol!
    @IBOutlet weak var groupTableView: UITableView!
    var activityIndicator = UIActivityIndicatorView()
    
    private let groupTodoCellID = "GroupTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupUIBarButtonItem()
        self.setupGroupTableView()
        self.setupActivityIndicator()
        
        self.presenter.didViewDidLoad()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Group"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupUIBarButtonItem() {
        let makeGroupButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"),
                                                  style: .plain, target: self, action: #selector(makeGroup(_:)))
       
        makeGroupButtonItem.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem = makeGroupButtonItem
    }
    
    func setupGroupTableView() {
        self.groupTableView.rowHeight = 96
        self.groupTableView.delegate = self
        self.groupTableView.dataSource = self
        self.groupTableView.emptyDataSetSource = self
        self.groupTableView.emptyDataSetDelegate = self
        self.groupTableView.tableFooterView = UIView()
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    /// plusボタン押されたときの処理gropuを作成する
    /// - Parameter sender: button
    @objc func makeGroup(_ sender: UIButton) {
        self.presenter.didTapMakeGroupButton()
    }
    
    func inject(with presenter: GroupTodoViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension GroupTodoViewController: GroupTodoViewPresenterOutput {
    func reloadGroupTableView() {
        DispatchQueue.main.async { self.groupTableView.reloadData() }
    }
    
    func startActivityIndicator() {
        DispatchQueue.main.async { self.activityIndicator.startAnimating() }
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
    }
    
    func showCreateNewGroupVC() {
        guard let createNewGroupVC = CreateNewGroupViewBuilder.create() as? CreateNewGroupViewController else { return }
        let navigationController = UINavigationController(rootViewController: createNewGroupVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func segueGroupDetailViewController(index: Int) {
        let groupDetailVC = GroupDetailViewBuilder.create(group: self.presenter.group[index], groupUsers: self.presenter.groupUsers[index])
        self.navigationController?.pushViewController(groupDetailVC, animated: true)
    }
}

extension GroupTodoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .none
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfGroup
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.groupTableView.dequeueReusableCell(withIdentifier: self.groupTodoCellID, for: indexPath)
                         as? GroupTableViewCell else { return UITableViewCell() }
        
        cell.configure(group: self.presenter.group[indexPath.item], user: self.presenter.groupUsers[indexPath.item])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.groupTableView.deselectRow(at: indexPath, animated: true)
        
        self.presenter.didTapGroupTableViewCell(index: indexPath.item)
    }
}

extension GroupTodoViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
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
