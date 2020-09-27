//
//  UserDetailViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/09/23.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke
import FSCalendar

final class UserDetailViewController: UIViewController {
    private var presenter: UserDetailViewPresenterProtocol!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var calenderView: FSCalendar!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupTaskLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var introductionButton: UIButton!
    
    
    internal let profileImageView = UIImageView()
    var activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupProfileImageView()
        self.setupNavigationBar()
        self.setupCalenderView()
        self.setupGroupImageView()
        self.setupGroupNameLabel()
        self.setupGroupTaskLabel()
        self.setupIntroductionLabel()
        self.setupIntroductionButton()
        self.setupActivityIndicator()
        
        self.presenter.didViewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.showNavigationImage(false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showNavigationImage(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.profileImageView.removeFromSuperview()
    }
    
    func setupView() {
        self.scrollView.delegate = self
    }
    
    func setupProfileImageView() {
        self.profileImageView.layer.borderWidth = 0.25
        self.profileImageView.layer.borderColor = UIColor.systemGray2.cgColor
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = self.presenter.user.name
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.tintColor = .systemGreen
        
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.addSubview(profileImageView)
        profileImageView.layer.cornerRadius = NavigationImageConst.ImageSizeForLargeState / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -NavigationImageConst.ImageRightMargin),
            profileImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -NavigationImageConst.ImageBottomMarginForLargeState),
            profileImageView.heightAnchor.constraint(equalToConstant: NavigationImageConst.ImageSizeForLargeState),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
    }
    
    func setupCalenderView() {
        self.calenderView.delegate = self
        self.calenderView.dataSource = self
    }
    
    func setupGroupImageView() {
        self.groupImageView.layer.borderWidth = 0.25
        self.groupImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.groupImageView.layer.cornerRadius = self.groupImageView.frame.width / 2
        self.groupImageView.layer.masksToBounds = true
    }
    
    func setupGroupNameLabel() {
        self.groupNameLabel.adjustsFontSizeToFitWidth = true
        self.groupNameLabel.minimumScaleFactor = 0.4
    }
    
    func setupGroupTaskLabel() {
        self.groupTaskLabel.adjustsFontSizeToFitWidth = true
        self.groupTaskLabel.minimumScaleFactor = 0.4
    }
    
    func setupIntroductionLabel() {
        self.introductionLabel.adjustsFontSizeToFitWidth = true
        self.introductionLabel.minimumScaleFactor = 0.4
    }
    
    func setupIntroductionButton() {
        //TODO:- Stringを切り分けること
        self.introductionButton.setTitle("ご紹介", for: .normal)
        self.introductionButton.backgroundColor = .systemBlue
        self.introductionButton.tintColor = .white
        self.introductionButton.layer.cornerRadius = 8
        self.introductionButton.layer.masksToBounds = true
    }
    
    func setupActivityIndicator() {
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.view.addSubview(self.activityIndicator)
    }
    
    private func showNavigationImage(_ show: Bool) {
        UIView.animate(withDuration: show ? 0.18 : 0.15) {
            self.profileImageView.alpha = show ? 1.0 : 0.0
        }
    }
    
    @IBAction func tapIntroductionButton(_ sender: Any) {
        self.presenter.didTapIntroductionButton()
    }
    
    
    func inject(with presenter: UserDetailViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension UserDetailViewController: UserDetailViewPresenterOutput {
    func setUserName() {
        DispatchQueue.main.async { self.navigationItem.title = self.presenter.user.name }
    }
    
    func setGroupName() {
        DispatchQueue.main.async { self.groupNameLabel.text = self.presenter.group.name }
    }
    
    func setGroupTask() {
        DispatchQueue.main.async { self.groupTaskLabel.text = self.presenter.group.task }
    }
    
    func setProfileImage(_ url: URL) {
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.defaultProfileImage())
            loadImage(with: url, options: options, into: self.profileImageView, progress: nil, completion: nil)
        }
    }
    
    func setGroupImage(_ url: URL) {
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.groupDefaultImage())
            loadImage(with: url, options: options, into: self.groupImageView, progress: nil, completion: nil)
        }
    }
    
    func reloadCalenderView() {
        DispatchQueue.main.async { self.calenderView.reloadData() }
    }
    
    func segueIntroductionShareTodoPlusVC() {
        
    }
    
    func moveAndResizeImage(scale: Double, xTranslation: Double, yTranslation: Double) {
        let scale = CGFloat(scale)
        let xTranslation = CGFloat(xTranslation)
        let yTranslation = CGFloat(yTranslation)
        DispatchQueue.main.async {
            self.profileImageView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale).translatedBy(x: xTranslation, y: yTranslation)
        }
    }
}

extension UserDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        self.presenter.didScrollViewDidScroll(height: Double(height))
    }
}

extension UserDetailViewController: FSCalendarDelegate, FSCalendarDataSource {
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        //TODO:- 以下はグループ作成日にすること
        let list = self.presenter.todoList.filter { $0.isFinished }.reduce([Date]()) { list, todo in
            var list = list
            guard todo.isFinished else { return list }
            guard let createdAt = todo.createdAt?.dateValue() else { return list }
            list.append(createdAt)
            return list
        }.sorted()
        
        guard let first = list.first else { return Date(timeIntervalSinceNow: -60 * 60 * 24 * 30) }
        return first
    }
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        guard calenderView.maximumDate >= date else { return nil } //最小の日(今日)以降はnil
        guard calenderView.minimumDate <= date else { return nil } //最後の日和前はnil
        
        //今日から1週間までは記録をする
        if self.presenter.getTheDayIsAWeekAgo(date: date) {
            if self.presenter.getContaintFinishedDate(date: date) {
                return UIImage(systemName: "checkmark.seal.fill")?.withTintColor(.systemGreen).withRenderingMode(.alwaysOriginal)
            }
            return UIImage(systemName: "xmark.seal.fill")?.withTintColor(.systemRed).withRenderingMode(.alwaysOriginal)
        }
        
        //1週間より前はロック状態によって変化させる
        return UIImage(systemName: "lock.fill")?.withTintColor(.systemOrange).withRenderingMode(.alwaysOriginal)
    }
}
