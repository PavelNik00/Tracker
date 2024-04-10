//
//  TabBarController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 08.04.2024.
//

import UIKit

final class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupNavigationBar()
        
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        borderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tabBar.addSubview(borderView)
        
        delegate = self
    }
    
    func setupViewControllers() {

        let trackerViewController = TrackerViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекер",
            image: UIImage(named: "icon_tracker_no_active"),
            selectedImage: UIImage(named: "icon_tracker_active"))
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "icon_statistic_no_active"),
            selectedImage: UIImage(named: "icon_statistic_active"))

        self.viewControllers = [trackerViewController, statisticViewController]
    }
    
    func setupNavigationBar() {
        let image = UIImage(named: "icon_plus")
        
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
    }
    
    @objc func addButtonTapped() {
        print("Add button tapped")
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Показываем или скрываем кнопку в зависимости от выбранного контроллера таб-бара
        if viewController is TrackerViewController {
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.leftBarButtonItem?.customView?.isHidden = false
        } else {
            navigationItem.leftBarButtonItem?.tintColor = .white
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.customView?.isHidden = true
        }
    }
}

