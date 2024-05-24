//
//  TabBarController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 08.04.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Overrides Methods

    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupViewControllers()
//        setupNavigationBar()
        
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        borderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tabBar.addSubview(borderView)
    }
    
    func setupViewControllers() {

        let trackerViewController = UINavigationController(
            rootViewController: TrackerViewController())
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекер",
            image: UIImage(named: "icon_tracker_no_active"),
            selectedImage: UIImage(named: "icon_tracker_active"))
        
        let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "icon_statistic_no_active"),
            selectedImage: UIImage(named: "icon_statistic_active"))
        
//        let navigationController = UINavigationController(rootViewController: trackerViewController)
        
        self.viewControllers = [trackerViewController, statisticViewController]
    }
    
//    func setupNavigationBar() {
//        let image = UIImage(named: "icon_plus")
//        
//        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
//        addButton.tintColor = .black
//        navigationItem.leftBarButtonItem = addButton
//    }
//    
//    @objc func addButtonTapped() {
//        print("Add button tapped")
//    }
}

