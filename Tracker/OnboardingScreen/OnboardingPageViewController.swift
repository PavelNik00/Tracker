//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 18.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIViewController {
    
    // массив хранения страниц для онбординга
    private lazy var pages: [UIViewController] = {
        let firstScreen = FirstOnboardingScreenViewController()
        let secondScreen = SecondOnboardingScreenViewController()
        return [firstScreen, secondScreen]
    }()
    
    
    
}
