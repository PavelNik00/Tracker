//
//  ChooseTypeOrTrackerVC.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.05.2024.
//

import UIKit

final class ChooseTypeOfTrackerVC: UIViewController, NewHabitCreateViewControllerDelegate, NewEventCreateViewControllerDelegate {
    
    weak var habitCreateDelegate: NewHabitCreateViewControllerDelegate?
    weak var eventCreateDelegate: NewEventCreateViewControllerDelegate?
    
    var didFinishCreatingHabitAndDismissCalled = false
    var didFinishCreatingEventAndDismissCalled = false
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let addNewHabitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    private let addNewIrregEventButton: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        addNewHabitButton.addTarget(self, action: #selector(setupNewHabitButton), for: .touchUpInside)
        addNewIrregEventButton.addTarget(self, action: #selector(setupNewEventButton), for: .touchUpInside)
        
        addNewHabitButton.translatesAutoresizingMaskIntoConstraints = false
        addNewIrregEventButton.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        view.addSubview(addNewHabitButton)
        view.addSubview(addNewIrregEventButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
            
            addNewHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewHabitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 343),
            addNewHabitButton.heightAnchor.constraint(equalToConstant: 60),
            addNewHabitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addNewHabitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            addNewIrregEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addNewIrregEventButton.topAnchor.constraint(equalTo: addNewHabitButton.bottomAnchor, constant: 16),
            addNewIrregEventButton.heightAnchor.constraint(equalToConstant: 60),
            addNewIrregEventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addNewIrregEventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
        
    }
    
    func didCreateHabit(with trackerCategoryString: TrackerCategory) {
        self.habitCreateDelegate?.didCreateHabit(with: trackerCategoryString)
    }
    
    func didCreateEvent(with trackerCategoryString: TrackerCategory) {
        self.eventCreateDelegate?.didCreateEvent(with: trackerCategoryString)
    }
    
    func didFinishCreatingHabitAndDismiss() {
        guard !didFinishCreatingHabitAndDismissCalled else {
            return
        }
        didFinishCreatingHabitAndDismissCalled = true
        
        dismiss(animated: true) {
            self.habitCreateDelegate?.didFinishCreatingHabitAndDismiss()
        }
    }
    
    func didFinishCreatingEventAndDismiss() {
        guard !didFinishCreatingEventAndDismissCalled else {
            return
        }
        didFinishCreatingEventAndDismissCalled = true
        
        dismiss(animated: true) {
            self.eventCreateDelegate?.didFinishCreatingEventAndDismiss()
        }
    }
    
    @objc func setupNewHabitButton() {
        let addNewHabitVC = NewHabitViewController()
        addNewHabitVC.habitCreateDelegate = self
        let addNavigationController = UINavigationController(rootViewController: addNewHabitVC)
        addNavigationController.modalPresentationStyle = .pageSheet
        present(addNavigationController, animated: true)
        print("Habit button tapped")
    }
    
    @objc func setupNewEventButton() {
        let addNewEventVC = NewEventViewController()
        addNewEventVC.eventCreateDelegate = self
        let addNavigationController = UINavigationController(rootViewController: addNewEventVC)
        addNavigationController.modalPresentationStyle = .pageSheet
        present(addNavigationController, animated: true)
        print("Irregular Event button tapped")
    }
}
