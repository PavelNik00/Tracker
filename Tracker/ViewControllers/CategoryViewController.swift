//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLabelHeader()
        setupErrorImage()
        setuplabelText()
        setupAddCategoryButton()
    }
    
    private func setupLabelHeader() {
        view.addSubview(labelHeader)
        labelHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            labelHeader.topAnchor.constraint(equalTo: view.topAnchor, constant: 22)])
    }
    
    private func setupErrorImage() {
        errorImage.image = UIImage(named: "icon_error")
        errorImage.translatesAutoresizingMaskIntoConstraints = false
        errorImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        errorImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        errorImage.clipsToBounds = true
        
        view.addSubview(errorImage)
        errorImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
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
        labelText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelText.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupAddCategoryButton() {
        view.addSubview(buttonAddCategory)
        buttonAddCategory.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            buttonAddCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonAddCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonAddCategory.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            buttonAddCategory.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
}
