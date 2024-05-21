//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.05.2024.
//

import UIKit

final class NewHabitViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addCategoryNameTextField = UITextField()
    
    let tableViewRows = ["Категория", "Расписание"]
    private let tableView = UITableView()
    
    let emojiArray = ["🙂","😻","🌺","🐶","❤️","😱",
                        "😇","😡","🥶","🤔","🙌","🍔",
                        "🥦","🏓","🥇","🎸","🏝️","😪",]
    
    let emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
       return emojiCollection
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(UIColor(named: "Red"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.addTarget(NewHabitViewController.self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(named: "Grey")
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(NewHabitViewController.self, action: #selector(addButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 22),
        ])
        
        setupAddCategoryNameTextField()
        setupButtons()
        setupTableView()
        setupEmojiCollection()
    }
    
    func setupAddCategoryNameTextField(){
        addCategoryNameTextField.placeholder = "Введите название трека"
        addCategoryNameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        addCategoryNameTextField.textColor = .black
        addCategoryNameTextField.textAlignment = .left
        addCategoryNameTextField.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        addCategoryNameTextField.layer.masksToBounds = true
        addCategoryNameTextField.layer.cornerRadius = 16
        addCategoryNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        addCategoryNameTextField.leftViewMode = .always
        
        
        view.addSubview(addCategoryNameTextField)
        addCategoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addCategoryNameTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            addCategoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addCategoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addCategoryNameTextField.heightAnchor.constraint(equalToConstant: 75)])
    }
    
    func setupButtons() {
        view.addSubview(cancelButton)
        view.addSubview(addButton)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 10),
            addButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    func setupTableView() {
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.layer.cornerRadius = 16
        tableView.backgroundView?.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: addCategoryNameTextField.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
        ])
    }
    
    func setupEmojiCollection() {
        
        view.addSubview(emojiCollection)
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.backgroundColor = .white
        
        emojiCollection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        
        NSLayoutConstraint.activate([
            emojiCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            emojiCollection.heightAnchor.constraint(equalToConstant: 230)
        ])
    }
    
    @objc func cancelButtonDidTap() {
        print("CancelButtonDidTap tapped")
    }
    
    @objc func addButtonDidTap() {
        print("AddButtonDidTap tapped")
    }
}

// настройка таблицы
extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = tableViewRows[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        
        let iconImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconImage.image = UIImage(named: "icon_next")
        cell.accessoryView = iconImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // прописываем логику при нажатии на ячейки таблицы
    }
}

// настройка коллекции emoji
extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiArray.count
    }
    
    // настройка ячейки коллекции
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell
        cell?.titleLabel.text = emojiArray[indexPath.row]
        cell?.titleLabel.font = .systemFont(ofSize: 32)
        cell?.titleLabel.textAlignment = .center
        cell?.contentView.backgroundColor = .white
        return cell!
    }
    
    // настройка выделения ячейки коллекции при тапе на нее
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = emojiCollection.cellForItem(at: indexPath)
        cell?.contentView.layer.cornerRadius = 16
        cell?.contentView.backgroundColor = UIColor(named: "Light Grey")
    }
    
    // настройка отмены выделения при тапе на другую ячейку в коллекции
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = emojiCollection.cellForItem(at: indexPath) as! EmojiCollectionViewCell
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.backgroundColor = .white
    }
    
    // настройка хедера
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = emojiCollection.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
        view.label.text = "Emoji"
        return view
    }
    
    // настройка отступа коллекции от хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    // настройка размеров хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
