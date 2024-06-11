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
        
        let borderView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 1))
        borderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        tabBar.addSubview(borderView)
    }
    
    func setupViewControllers() {
        
        let trackerViewController = UINavigationController(
            rootViewController: TrackerViewController(categories: [], completedTrackers: [], newCategories: []))
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекер",
            image: UIImage(named: "icon_tracker_no_active"),
            selectedImage: UIImage(named: "icon_tracker_active"))
        
        let statisticViewController = UINavigationController(rootViewController: StatisticViewController())
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "icon_statistic_no_active"),
            selectedImage: UIImage(named: "icon_statistic_active"))
        
        self.viewControllers = [trackerViewController, statisticViewController]
    }
}

