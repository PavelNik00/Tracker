//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

protocol CreateNewCategoryViewControllerDelegate: AnyObject {
    func didCreatedCategory(_ createdCategory: TrackerCategory)
}

// класс для создания новой категории
final class CreateNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: CreateNewCategoryViewControllerDelegate?
    var onDismiss: (() -> Void)?
    
    convenience init(delegate: CreateNewCategoryViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    private var category: TrackerCategory?
    private var categories: [TrackerCategory] = []
    private var enteredText: String = ""
    
    private let labelHeader: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let newCategoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        textField.textAlignment = .left
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 75))
        textField.leftViewMode = .always
        textField.addTarget(self, action: #selector(textFieldEditing(_:)), for: .editingChanged)
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
        button.addTarget(self, action: #selector(createCategoryButton), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        newCategoryTextField.delegate = self
        
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
        view.addSubview(newCategoryTextField)
        newCategoryTextField.translatesAutoresizingMaskIntoConstraints = false
        newCategoryTextField.clearButtonMode = .whileEditing
        
        NSLayoutConstraint.activate([
            newCategoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            newCategoryTextField.heightAnchor.constraint(equalToConstant: 75)
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
    
    @objc func textFieldEditing(_ textField: UITextField) {
        if let enteredText = textField.text {
            !enteredText.isEmpty ? readyButtonIsActive() : readyButtonIsNotActive()
        }
    }
    
    private func readyButtonIsActive() {
        readyButton.isEnabled = true
        readyButton.backgroundColor = .black
    }
    
    private func readyButtonIsNotActive() {
        readyButton.isEnabled = false
        readyButton.backgroundColor = UIColor(named: "Grey")
    }
    
    // обрабатываем нажатие кнопки Готово
    @objc func createCategoryButton() {
        guard let newCategoryName = newCategoryTextField.text, !newCategoryName.isEmpty else { return }
        
        let newCategory = TrackerCategory(header: newCategoryName, trackers: nil)
        self.categories.append(newCategory)
        
        delegate?.didCreatedCategory(newCategory)
        
        dismiss(animated: true) {
            self.onDismiss?()
        }
        print(" ✅ Новая категория \(newCategoryName) создана")
    }
}
