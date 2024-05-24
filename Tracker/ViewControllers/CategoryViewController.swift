//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

// класс для страницы Категория
final class CategoryViewController: UIViewController {
    
    var categories = [String]() {
        didSet {
            dataUpdated?()
        }
    }
    
    var dataUpdated: ( () -> Void )?
    
    private let labelHeader: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let errorImage = UIImageView()
    private let labelText = UILabel()
    
    private var buttonAddCategory: UIButton = {
        let button = UIButton()
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    let categoryTableView: UITableView = {
        let tableView = UITableView()
        
        tableView.layer.cornerRadius = 16
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLabelHeader()
        setupScreen()
        setupAddCategoryButton()

    }
    
    private func setupCategoryTableView() {
        view.addSubview(categoryTableView)
        
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.backgroundColor = .white
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        
        NSLayoutConstraint.activate([
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: -16),
            categoryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            categoryTableView.bottomAnchor.constraint(equalTo: buttonAddCategory.topAnchor, constant: -20)
        ])
    }
    
    private func setupLabelHeader() {
        view.addSubview(labelHeader)
        labelHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 22)
        ])
    }
    
    private func setupErrorImage() {
        errorImage.image = UIImage(named: "icon_error")
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        errorImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        errorImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        errorImage.clipsToBounds = true
        
        view.addSubview(errorImage)
        NSLayoutConstraint.activate([
            errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setuplabelText() {
        labelText.translatesAutoresizingMaskIntoConstraints = false
        labelText.text = "Привычки и события можно \nобъединить по смыслу"
        labelText.font = .systemFont(ofSize: 12, weight: .medium)
        labelText.textColor = .black
        labelText.numberOfLines = 0
        labelText.lineBreakMode = .byWordWrapping
//        labelText.sizeToFit()
        labelText.textAlignment = .center
        
        view.addSubview(labelText)
        NSLayoutConstraint.activate([
            labelText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelText.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8)
        ])
    }
    
    private func setupAddCategoryButton() {
        view.addSubview(buttonAddCategory)
        buttonAddCategory.translatesAutoresizingMaskIntoConstraints = false
        buttonAddCategory.addTarget(self, action: #selector(addCategoryButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            buttonAddCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonAddCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonAddCategory.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            buttonAddCategory.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupScreen() {
        if categories.isEmpty {
            setupErrorImage()
            setuplabelText()
        } else {
            setupCategoryTableView()
        }
    }
    
    @objc func addCategoryButton() {
        let navigationViewController = UINavigationController(rootViewController: NewCategoryViewController())
        navigationViewController.modalPresentationStyle = .pageSheet
        present(navigationViewController, animated: true)
        print("Button \(buttonAddCategory) tapped")
    }
}

// настройка таблицы с созданными категориями
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    // количество категорий
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    // настройка ячейки категории
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.titleLabel.text = categories[indexPath.row]
        cell.contentView.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        
        return cell
    }
    
    
}
