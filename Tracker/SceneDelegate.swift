//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // Проверяем, был ли уже показан экран онбординга
        let hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
        
        if hasSeenOnboarding {
            // Если онбординг уже был показан, показываем основной экран
            window?.rootViewController = TabBarController()
        } else {
            // Если нет, показываем экран онбординга
            window?.rootViewController = OnboardingPageViewController()
        }
        
        window?.makeKeyAndVisible()
        
    }
    
    func sceneDidDisconnect(_ scene: UIScene) { }
    
    func sceneDidBecomeActive(_ scene: UIScene) { }
    
    func sceneWillResignActive(_ scene: UIScene) { }
    
    func sceneWillEnterForeground(_ scene: UIScene) { }
    
    func sceneDidEnterBackground(_ scene: UIScene) { }

    // Метод для обновления корневого контроллера
    func switchToTabBarController() {
        let tabBarController = TabBarController()
        window?.rootViewController = tabBarController
        
        // Устанавливаем флаг, что онбординг был показан
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }
}
