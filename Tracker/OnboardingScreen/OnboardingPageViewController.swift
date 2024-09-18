//
//  OnboardingPageViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 18.09.2024.
//

import UIKit

final class OnboardingPageViewController: UIPageViewController {
    
    // массив для хранение страниц онбординга
    private lazy var pages: [UIViewController] = {
        let firstScreen = FirstOnboardingScreenViewController()
        let secondScreen = SecondOnboardingScreenViewController()
        return [firstScreen, secondScreen]
    }()
    
    // cоздаем индикатор страницы
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor(named: "Black [day]")
        pageControl.pageIndicatorTintColor = UIColor(named: "Grey")
        pageControl.currentPage = 0
        pageControl.numberOfPages = pages.count
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // cоздаем кнопку "Пропустить"
    private lazy var skipButton: UIButton = {
        let button  = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "Black [day]")
        button.tintColor = UIColor(named: "White [day]")
        button.setTitle("Вот это технологии!", for: .normal)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(skipButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // настраиваем параметры перехода страниц для UIPageViewController
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // Устанавливаем ограничения для UI-элементов на экране онбординга
    private func setupConstraints() {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(skipButton.heightAnchor.constraint(equalToConstant: 60))
        constraints.append(skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20))
        constraints.append(skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20))
        constraints.append(skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50))
        
        constraints.append(pageControl.bottomAnchor.constraint(equalTo: skipButton.topAnchor, constant: -24))
        constraints.append(pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // настраиваем представление и его компоненты
    private func setupView() {
        view.addSubview(skipButton)
        view.addSubview(pageControl)
        
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // действие для кнопки "Пропустить", которое переходит к основному экрану
    @objc private func skipButtonClicked() {
        guard let sceneDelegate = UIApplication.shared.connectedScenes
                .compactMap({ $0.delegate as? SceneDelegate })
                .first else {
            fatalError("Ошибка с инициализацией SceneDelegate")
        }
        
        // Меняем корневой контроллер на TabBarController и устанавливаем флаг
        sceneDelegate.switchToTabBarController()
    }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {
    
    // метод, возвращающий контроллер предыдущей страницы
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else  {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return pages.last
        }
        return pages[previousIndex]
    }
    
    // метод, возвращающий контроллер следующей страницы
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < pages.count else {
            return pages.first
        }
        return pages[nextIndex]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {
    
    // метод, обновляющий индикатор текущей страницы
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

