//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ selectedCategory: String?)
}

final class CategoryViewController: UIViewController, CreateNewCategoryViewControllerDelegate {
    
    weak var delegate: CategoryViewControllerDelegate?
    var categoryToPass: ( (String) -> Void )?
    var categories: [TrackerCategory] = []
    
    var selectedIndexPath: IndexPath?
    var selectedCategory: String?
    
    var dataUpdated: ( () -> Void )?
    
    private var isCheckmarkImageSelected: Bool = false
    
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
    
    let categoryTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupLabelHeader()
        setupScreen()
        setupAddCategoryButton()
        
    }
    
    private func setupCategoryTableView() {
        view.addSubview(categoryTableView)
        
        categoryTableView.register(CategoryCell.self, forCellReuseIdentifier: "CategoryCell")
        
        categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        categoryTableView.backgroundColor = .white
        
        categoryTableView.dataSource = self
        categoryTableView.delegate = self
        
        
        NSLayoutConstraint.activate([
            categoryTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            categoryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100)
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
            setupAddCategoryButton()
        } else {
            setupCategoryTableView()
            setupAddCategoryButton()
        }
    }
    
    func passCategoryToCreatingTrackerVC(selectedCategory: String) {
        
        let trackerCategory = TrackerCategory(header: selectedCategory, trackers: nil)
        categories.append(trackerCategory)
        categoryToPass?(trackerCategory.header)
        //        navigationController?.popViewController(animated: true)
        setupCategoryTableView()
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true ) { [weak self ] in
                guard (self?.categories) != nil else { return }
                self?.delegate?.didSelectCategory(selectedCategory)
            }
        }
    }
    
    @objc func addCategoryButton() {
        
        if isCheckmarkImageSelected == true {
            guard let selectedCategory = selectedCategory else { return }
            passCategoryToCreatingTrackerVC(selectedCategory: selectedCategory)
            print("Button Готово tapped")
        } else {
            let createNewCategoryVC = CreateNewCategoryViewController()
            createNewCategoryVC.delegate = self
            let navigationViewController = UINavigationController(rootViewController: createNewCategoryVC)
            navigationViewController.modalPresentationStyle = .pageSheet
            present(navigationViewController, animated: true)
            print("Button Добавить категорию tapped")
            print(#fileID, #function, #line)
            
        }
    }
    
    func didCreatedCategory(_ createdCategory: TrackerCategory) {
        categories.append(createdCategory)
        
        let newIndexPath = IndexPath(row: categories.count - 1, section: 0)
        categoryTableView.insertRows(at: [newIndexPath], with: .automatic)
        
        setupScreen()
        delegate?.didSelectCategory(selectedCategory)
        categoryTableView.reloadData()
        dataUpdated?()
    }
}

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        
        cell.categoryLabel.text = categories[indexPath.row].header
        cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        
        if indexPath == selectedIndexPath {
            cell.checkmarkImage.isHidden = false
        } else {
            cell.checkmarkImage.isHidden = true
        }
        
        let isLast = indexPath.row == (categories.count - 1)
        let isFirst = indexPath.row == 0
        
        if isFirst && isLast {
            cell.layer.cornerRadius = 16
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.width + 1)
        } else if isFirst {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        } else if isLast {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.frame.width + 1)
        } else {
            cell.layer.cornerRadius = 0
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let selectedIndexPath = selectedIndexPath,
           let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? CategoryCell {
            selectedCell.checkmarkImage.isHidden = true
            updateCategoryButtonTitle()
            tableView.reloadData()
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.checkmarkImage.isHidden = false
            isCheckmarkImageSelected = !cell.checkmarkImage.isHidden
            selectedIndexPath = indexPath
            selectedCategory = categories[indexPath.row].header
            updateCategoryButtonTitle()
            tableView.reloadData()
        }
    }
    
    private func updateCategoryButtonTitle() {
        let categoryButton = view.subviews.compactMap { $0 as? UIButton }.first
        categoryButton?.setTitle(isCheckmarkImageSelected ? "Готово" : "Добавить категорию", for: .normal)
    }
}
