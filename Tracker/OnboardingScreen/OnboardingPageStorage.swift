//
//  OnboardingPageStorage.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 18.09.2024.
//

import UIKit

final class OnboardingPageStorage {
    
    // синглтон для хранения состояния онбординга
    static let shared = OnboardingPageStorage()
    private var userDefaults = UserDefaults.standard
    private init() { }
    
    // проверяем был ли показан онбординг
    var checkSecondSetup: Bool {
        get {
            userDefaults.bool(forKey: "checkingSetup")
        }
        set {
            userDefaults.setValue(newValue, forKey: "checkingSetup")
        }
    }
    
}
