//
//  ChooseTypeOrTrackerVC.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.05.2024.
//

import UIKit

final class ChooseTypeOfTrackerVC: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Создание трекера"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private var addNewHabitButton: UIButton = {
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
        addNewIrregEventButton.addTarget(self, action: #selector(setupIrregEventButton), for: .touchUpInside)
        
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
    
    @objc func setupNewHabitButton() {
        print("Habit button tapped")
    }
    
    @objc func setupIrregEventButton() {
        print("Irregular Event button tapped")
    }
}
