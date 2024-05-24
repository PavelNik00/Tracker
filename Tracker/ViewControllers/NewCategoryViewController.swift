//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

// класс для создания новой категории
final class NewCategoryViewController: UIViewController {
    
    private let labelHeader: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        textField.textAlignment = .left
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 75))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldEditing), for: .editingChanged)
        return textField
    }()
    
    private let readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "Grey")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(readyButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLabelHeader()
        setupTextField()
        setupReadyButton()
    }
    
    func setupLabelHeader() {
        view.addSubview(labelHeader)
        labelHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
        ])
    }
    
    func setupTextField() {
        view.addSubview(textField)
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            textField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setupReadyButton() {
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func readyButtonIsActive() {
        readyButton.isEnabled = true
        readyButton.backgroundColor = .black
    }
    
    private func readyButtonIsNotActive() {
        readyButton.isEnabled = false
        readyButton.backgroundColor = UIColor(named: "Grey")
    }
    
    @objc func textFieldEditing(_ sender: UITextField) {
        if let text = sender.text {
            !text.isEmpty ? readyButtonIsActive() : readyButtonIsNotActive()
        }
    }
    
    @objc func readyButtonTapped(_ sender: UIButton) {
        guard let newCategoryName = textField.text else { return }
    }
}
