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

final class CreateNewCategoryViewController: UIViewController, UITextFieldDelegate {
    
    weak var delegate: CreateNewCategoryViewControllerDelegate?
    var onDismiss: (() -> Void)?
    
    private var category: TrackerCategory?
    private var categories: [TrackerCategory] = [] {
        didSet {
            onDismiss?()
        }
    }
    private var enteredText: String = ""
    
    private let categoryStore = TrackerCategoryStore.shared
    
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
    
    convenience init(delegate: CreateNewCategoryViewControllerDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        newCategoryTextField.delegate = self
        
        setupLabelHeader()
        setupTextField()
        setupReadyButton()
        
        let tapGuesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(hideKeyboard))
        tapGuesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGuesture)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func readyButtonIsActive() {
        readyButton.isEnabled = true
        readyButton.backgroundColor = .black
    }
    
    private func readyButtonIsNotActive() {
        readyButton.isEnabled = false
        readyButton.backgroundColor = UIColor(named: "Grey")
    }
    
    @objc func textFieldEditing(_ textField: UITextField) {
        if let enteredText = textField.text {
            !enteredText.isEmpty ? readyButtonIsActive() : readyButtonIsNotActive()
        }
    }
    
    @objc func createCategoryButton() {
        
        guard let newCategoryName = newCategoryTextField.text, !newCategoryName.isEmpty else { return }
        
        do {
            
            try categoryStore.createCategoryCoreData(with: newCategoryName)
            
            print(" ✅ Новая категория \(newCategoryName) добавлена в Core Data")
        } catch {
            fatalError("Ошибка при создании категории")
        }
        
        dismiss(animated: true) {
            self.delegate?.didCreatedCategory(TrackerCategory(header: newCategoryName, trackers: nil))
            self.onDismiss?()
        }
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}
