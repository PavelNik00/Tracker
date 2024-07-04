//
//  NewHabitViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.05.2024.
//

import UIKit

protocol NewHabitCreateViewControllerDelegate: AnyObject {
    func didCreateHabit(with trackerCategoryString: TrackerCategory)
    func didFinishCreatingHabitAndDismiss()
}

final class NewHabitViewController: UIViewController, CategoryViewControllerDelegate {
    
    weak var addCategoryDelegate: CategoryViewControllerDelegate?
    weak var habitCreateDelegate: NewHabitCreateViewControllerDelegate?
    
    var selectedHabitName: [Tracker]? = []
    var onDismiss: (() -> Void)?

    private var selectedDays: String?
    private var selectedCategory: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategoryStringForHabit: String?
    
    private var tableViewTopConstraint: NSLayoutConstraint?
    
    private let limitTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .red
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private let tableViewRows = ["Категория", "Расписание"]
    private let tableView = UITableView()
    
    private let emojiArray = ["🙂","😻","🌺","🐶","❤️","😱",
                      "😇","😡","🥶","🤔","🙌","🍔",
                      "🥦","🏓","🥇","🎸","🏝️","😪",]
    
    private let emojiCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let emojiCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return emojiCollection
    }()
    
    private let colorArray: [UIColor] = {
        let colorNames = [
            "Color selection 1", "Color selection 2", 
            "Color selection 3", "Color selection 4",
            "Color selection 5", "Color selection 6", 
            "Color selection 7", "Color selection 8",
            "Color selection 9", "Color selection 10", 
            "Color selection 11", "Color selection 12",
            "Color selection 13", "Color selection 14", 
            "Color selection 15", "Color selection 16",
            "Color selection 17", "Color selection 18"
        ]
        
        var colors: [UIColor] = []
        for name in colorNames {
            if let color = UIColor(named: name) {
                colors.append(color)
            } else {
                print("Ошибка: Цвет с именем \(name) не найден в ассетах.")
                colors.append(UIColor.black)
            }
        }
        return colors
    }()
    
    private let colorCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let colorCollection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return colorCollection
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
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(addButtonDidTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Новая привычка"
        view.backgroundColor = .white
                
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        setupScrollView()
        setupContentView()
        
        setupAddCategoryNameTextField()
        setuplimitTextLabel()
        
        setupTableView()
        setupEmojiCollection()
        setupColorCollection()
        setupButtons()
        updateCreateButtonState()
        
        limitTextLabel.addObserver(self, forKeyPath: "hidden", options: [.old, .new], context: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyBoard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "hidden", let label = object as? UILabel {
            tableViewTopConstraint?.constant = label.isHidden ? 20 : 60
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    deinit {
        limitTextLabel.removeObserver(self, forKeyPath: "hidden")
    }
    
    func finishCreatingHabitAndDismiss() {
        dismiss(animated: false) {
            self.habitCreateDelegate?.didFinishCreatingHabitAndDismiss()
            print("Вызов делегата на чтобы закрыть привычкувью")
        }
    }
    
    func didSelectCategory(_ selectedCategory: String?) {
        self.selectedCategoryStringForHabit = selectedCategory
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    func updateCreateButtonState() {
        guard selectedCategory != nil ,
              selectedDays != nil,
              selectedEmoji != nil,
              selectedColor != nil,
              addCategoryNameTextField.text?.isEmpty == false
                
        else {
            addButton.isEnabled = false
            return
        }
        addButton.isEnabled = true
        addButton.backgroundColor = .black
    }
    
    private func setupScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContentView() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setuplimitTextLabel() {
        contentView.addSubview(limitTextLabel)
        limitTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            limitTextLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            limitTextLabel.topAnchor.constraint(equalTo: addCategoryNameTextField.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupAddCategoryNameTextField(){
        addCategoryNameTextField.placeholder = "Введите название трека"
        addCategoryNameTextField.font = .systemFont(ofSize: 17, weight: .regular)
        addCategoryNameTextField.textColor = .black
        addCategoryNameTextField.textAlignment = .left
        addCategoryNameTextField.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        addCategoryNameTextField.layer.masksToBounds = true
        addCategoryNameTextField.layer.cornerRadius = 16
        addCategoryNameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 75))
        addCategoryNameTextField.leftViewMode = .always
        addCategoryNameTextField.clearButtonMode = .whileEditing
        addCategoryNameTextField.delegate = self
        addCategoryNameTextField.addTarget(self, action: #selector(addCategoryNameTextFieldEditing(_:)), for: .editingChanged)
        
        
        contentView.addSubview(addCategoryNameTextField)
        addCategoryNameTextField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addCategoryNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            addCategoryNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addCategoryNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addCategoryNameTextField.heightAnchor.constraint(equalToConstant: 75)])
    }
    
    private func setupTableView() {
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.layer.cornerRadius = 16
        tableView.backgroundView?.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: addCategoryNameTextField.bottomAnchor, constant: limitTextLabel.isHidden ? 20 : 60)
        tableViewTopConstraint?.isActive = true
        
        if limitTextLabel.isHidden == true {
            NSLayoutConstraint.activate([
                //                tableView.topAnchor.constraint(equalTo: addCategoryNameTextField.bottomAnchor, constant: 20),
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 150),
            ])
        }
    }
    
    private func setupEmojiCollection() {
        
        contentView.addSubview(emojiCollection)
        emojiCollection.translatesAutoresizingMaskIntoConstraints = false
        emojiCollection.backgroundColor = .white
        
        emojiCollection.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        emojiCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        emojiCollection.dataSource = self
        emojiCollection.delegate = self
        emojiCollection.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            emojiCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            emojiCollection.heightAnchor.constraint(equalToConstant: 230)
        ])
    }
    
    private func setupColorCollection() {
        
        contentView.addSubview(colorCollection)
        colorCollection.translatesAutoresizingMaskIntoConstraints = false
        colorCollection.backgroundColor = .white
        
        colorCollection.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        colorCollection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        colorCollection.dataSource = self
        colorCollection.delegate = self
        colorCollection.keyboardDismissMode = .onDrag
        
        NSLayoutConstraint.activate([
            colorCollection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 20),
            colorCollection.heightAnchor.constraint(equalToConstant: 230)
        ])
    }
    
    private func setupButtons() {
        contentView.addSubview(cancelButton)
        contentView.addSubview(addButton)
        
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: colorCollection.bottomAnchor, constant: 30),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 10),
            addButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            
            addButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            addButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc func addCategoryNameTextFieldEditing(_ textField: UITextField) {
        guard let enteredText = textField.text, !enteredText.isEmpty else { return }
        updateCreateButtonState()
        print("Введен так \(enteredText)")
    }
    
    @objc func cancelButtonDidTap() {
        self.dismiss(animated: true, completion: nil)
        print("Нажата кнопка Отменить")
    }
    
    @objc func addButtonDidTap() {
        guard let selectedHabitName = addCategoryNameTextField.text, !selectedHabitName.isEmpty,
              let selectedCategoryString = selectedCategory,
              !selectedCategoryString.isEmpty,
              let selectedColorSting = selectedColor,
              let selectedEmojiString = selectedEmoji, !selectedEmojiString.isEmpty,
              let selectedDays = selectedDays
        else {
            print("Чего-то не хватает")
            return
        }
        
        let scheduleComponents = selectedDays.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let tracker = Tracker(id: UUID(), name: selectedHabitName, color: selectedColorSting, emoji: selectedEmojiString, schedule: scheduleComponents)
        
        let trackerCategoryString = TrackerCategory(header: selectedCategoryString, trackers: [tracker])
        
        if let delegate = habitCreateDelegate {
            delegate.didCreateHabit(with: trackerCategoryString)
            print("Вызов делегата на создании привычки")
        }
        
        finishCreatingHabitAndDismiss()
        print("✅ Новая привычка c названием категории \(selectedCategoryString), названием привычки \(selectedHabitName), выбранным эмодзи \(selectedEmojiString), выбранным цветом \(selectedColorSting), и выбранными днями \(scheduleComponents) создана")
    }
    
    @objc private func hideKeyBoard() {
        self.view.endEditing(true)
    }
}

extension NewHabitViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newText = (text as NSString).replacingCharacters(in: range, with: string)
        
        if newText.count <= 37 {
            limitTextLabel.isHidden = true
            textField.textColor = .black
        } else {
            limitTextLabel.isHidden = false
            textField.textColor = .red
        }
        
        return newText.count <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewHabitViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableViewRows[indexPath.row]
        if cell == "Категория" {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryCell")
            cell.textLabel?.text = tableViewRows[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .black
            cell.detailTextLabel?.text = selectedCategory ?? ""
            cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
            cell.selectionStyle = .none
            
            let iconImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            iconImage.image = UIImage(named: "icon_next")
            cell.accessoryView = iconImage
            
            if indexPath.row == tableViewRows.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            
            updateCreateButtonState()
            return cell
        } else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.textLabel?.text = tableViewRows[indexPath.row]
            cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
            cell.detailTextLabel?.textColor = .black
            cell.detailTextLabel?.text = selectedDays ?? ""
            cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
            cell.selectionStyle = .none
            
            let iconImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
            iconImage.image = UIImage(named: "icon_next")
            cell.accessoryView = iconImage
            
            if indexPath.row == tableViewRows.count - 1 {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            }
            updateCreateButtonState()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableViewRows[indexPath.row]
        if cell == "Категория" {
            let navigationVC = CategoryViewController()
            navigationVC.categoryToPass = { [weak self]  selectedCategory in
                self?.selectedCategory = selectedCategory
                tableView.reloadRows(at: [indexPath], with: .automatic)
                print("✅ Категория \(selectedCategory) добавлена в таблицу")
            }
            navigationVC.modalPresentationStyle = .pageSheet
            present(navigationVC, animated: true)
        } else {
            let navigationVC = ScheduleViewController()
            navigationVC.scheduleToPass = { [weak self] selectedDays in
                self?.selectedDays = selectedDays
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            navigationVC.modalPresentationStyle = .pageSheet
            present(navigationVC, animated: true)
            print("✅ Дата добавлена")
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension NewHabitViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollection {
            emojiArray.count
        } else {
            colorArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollection {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCollectionViewCell
            cell?.titleLabel.text = emojiArray[indexPath.row]
            cell?.titleLabel.font = .systemFont(ofSize: 32)
            cell?.titleLabel.textAlignment = .center
            cell?.contentView.backgroundColor = .white
            
            return cell!
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
            let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            view.layer.cornerRadius = 8
            view.backgroundColor = colorArray[indexPath.row]
            view.layer.masksToBounds = true
            cell.contentView.addSubview(view)
            view.center = CGPoint(x: cell.contentView.bounds.midX,
                                  y: cell.contentView.bounds.midY)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            let cell = emojiCollection.cellForItem(at: indexPath)
            cell?.contentView.layer.cornerRadius = 16
            cell?.contentView.backgroundColor = UIColor(named: "Light Grey")
            selectedEmoji = emojiArray[indexPath.row]
            updateCreateButtonState()
            print("Выбран эмодзи \(selectedEmoji ?? "")")
        } else {
            let cell = colorCollection.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 3
            cell?.layer.cornerRadius = 8
            cell?.layer.borderColor = colorArray[indexPath.row].cgColor
            selectedColor = colorArray[indexPath.row]
            updateCreateButtonState()
            print("Выбран цвет \(selectedColor ?? UIColor.black)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollection {
            guard let cell = emojiCollection.cellForItem(at: indexPath) as? EmojiCollectionViewCell else {
                print("Ошибка: Не удалось создать ячейку EmojiCollectionViewCell")
                return
            }
            
            cell.contentView.layer.cornerRadius = 0
            cell.contentView.backgroundColor = .white
            
            if selectedEmoji == emojiArray[indexPath.row] {
                selectedEmoji = nil
            }
            updateCreateButtonState()
        } else {
            let cell = colorCollection.cellForItem(at: indexPath)
            cell?.layer.borderWidth = 0
            
            if selectedColor == colorArray[indexPath.row] {
                selectedColor = nil
            }
            updateCreateButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as? SupplementaryView else {
            print("Ошибка: Не удалось создать SupplementaryView")
            return UICollectionReusableView()
        }
        
        if collectionView == emojiCollection {
            view.label.text = "Emoji"
        } else {
            view.label.text = "Colors"
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
