//
//  FirstSetupViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 18.09.2024.
//

import UIKit

final class FirstSetupViewController: UIViewController {
    
    // шерим достук к синглтону
    private let firstLaunchStorage = OnboardingPageStorage.shared
    
    // проверяем надо ли показывать онбординг
    private func checkFirstSetup() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Не удалось инициализировать AppDelegate")
        }
        
        // если не был показан – проверяем и показываем
        if firstLaunchStorage.checkSecondSetup == false {
            appDelegate.window?.rootViewController = OnboardingPageViewController()
            firstLaunchStorage.checkSecondSetup = true
        } else {
            
            // если был показан - переходим к основному экрану
            appDelegate.window?.rootViewController = TabBarController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkFirstSetup()
    }
    
}
