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

final class CategoryViewController: UIViewController, CreateNewCategoryViewControllerDelegate, TrackerCategoryDelegate {
    
    weak var delegate: CategoryViewControllerDelegate?
    var categoryToPass: ((String) -> Void)?
    var categories: [TrackerCategory] = []
    var dataUpdated: (() -> Void)?
    
    private var selectedIndexPath: IndexPath?
    private var selectedCategory: String?
    private var isCheckmarkImageSelected: Bool = false
    
    private let categoryStore = TrackerCategoryStore.shared
    
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
    private let categoryTableView = UITableView()
    
    private let buttonAddCategory: UIButton = {
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
        
        categoryStore.delegate = self
        trackerCategoryDidUpdate()
        
        setupLabelHeader()
        setupScreen()
        setupAddCategoryButton()
    }
    
    func trackerCategoryDidUpdate() {
        categories = categoryStore.categories
        categoryTableView.reloadData()
    }
    
    func passCategoryToCreatingTrackerVC(selectedCategory: String) {
        let trackerCategory = TrackerCategory(header: selectedCategory, trackers: nil)
        categories.append(trackerCategory)
        categoryToPass?(trackerCategory.header)
        setupCategoryTableView()
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true ) { [weak self] in
                guard let self = self else { return }
                self.delegate?.didSelectCategory(selectedCategory)
            }
        }
    }
    
    func didCreatedCategory(_ createdCategory: TrackerCategory) {
        categories.append(createdCategory)
                
        categoryTableView.beginUpdates()
        categoryTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        categoryTableView.endUpdates()
        dataUpdated?()

        setupScreen()
        delegate?.didSelectCategory(selectedCategory)
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
            categoryTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
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
            trackerCategoryDidUpdate()
        }
    }
    
    @objc func addCategoryButton() {
        if isCheckmarkImageSelected {
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
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as? CategoryCell else {
            print("Ошибка: Не удалось создать ячейку CategoryCell")
            return UITableViewCell()
        }
        
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
        
        if selectedIndexPath == indexPath {
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                cell.checkmarkImage.isHidden = true
            }
            selectedIndexPath = nil
            selectedCategory = nil
            isCheckmarkImageSelected = false
            updateCategoryButtonTitle()
        } else {
            if let selectedIndexPath = selectedIndexPath,
               let selectedCell = tableView.cellForRow(at: selectedIndexPath) as? CategoryCell {
                selectedCell.checkmarkImage.isHidden = true
            }
            
            if let cell = tableView.cellForRow(at: indexPath) as? CategoryCell {
                cell.checkmarkImage.isHidden = false
            }
            selectedIndexPath = indexPath
            selectedCategory = categories[indexPath.row].header
            isCheckmarkImageSelected = true
            updateCategoryButtonTitle()
        }
        
        tableView.reloadData()
    }
    
    private func updateCategoryButtonTitle() {
        let categoryButton = view.subviews.compactMap { $0 as? UIButton }.first
        categoryButton?.setTitle(isCheckmarkImageSelected ? "Готово" : "Добавить категорию", for: .normal)
    }
}
