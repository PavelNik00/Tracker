//
//  NewEventViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 07.06.2024.
//

import UIKit

protocol NewEventCreateViewControllerDelegate: AnyObject {
    func didCreateEvent(with trackerCategoryString: TrackerCategory)
    func didFinishCreatingEventAndDismiss()
}

final class NewEventViewController: UIViewController, CategoryViewControllerDelegate {
    
    let datePicker = UIDatePicker()
    
    var currentDate: Date = Date()
    var onDismiss: (() -> Void)?
    
    weak var addCategoryDelegate: CategoryViewControllerDelegate?
    weak var eventCreateDelegate: NewEventCreateViewControllerDelegate?
    
    private var selectedHabitName: [Tracker]? = []
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
        label.text = "Новое нерегулярное событие"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addCategoryNameTextField = UITextField()
    
    private let tableViewRows = "Категория"
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
    
    private let colorArray: [UIColor] = [
        UIColor(named: "Color selection 1")!, UIColor(named: "Color selection 2")!,
        UIColor(named: "Color selection 3")!, UIColor(named: "Color selection 4")!,
        UIColor(named: "Color selection 5")!, UIColor(named: "Color selection 6")!,
        UIColor(named: "Color selection 7")!, UIColor(named: "Color selection 8")!,
        UIColor(named: "Color selection 9")!, UIColor(named: "Color selection 10")!,
        UIColor(named: "Color selection 11")!, UIColor(named: "Color selection 12")!,
        UIColor(named: "Color selection 13")!, UIColor(named: "Color selection 14")!,
        UIColor(named: "Color selection 15")!, UIColor(named: "Color selection 16")!,
        UIColor(named: "Color selection 17")!, UIColor(named: "Color selection 18")!,
    ]
    
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
        
        self.title = "Новое нерегулярное событие"
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
        
        let tapGuesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(hideKeyboard))
        tapGuesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGuesture)
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
    
    func didSelectCategory(_ selectedCategory: String?) {
        self.selectedCategoryStringForHabit = selectedCategory
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    func updateCreateButtonState() {
        guard selectedCategory != nil ,
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
    
    func finishCreatingEventAndDismiss() {
        dismiss(animated: false) {
            print("Перед вызовом делегата didFinishCreatingEventAndDismiss: \(self.eventCreateDelegate != nil)")
            self.eventCreateDelegate?.didFinishCreatingEventAndDismiss()
            print("Вызов делегата на чтобы закрыть событие")
        }
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
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableViewTopConstraint = tableView.topAnchor.constraint(equalTo: addCategoryNameTextField.bottomAnchor, constant: limitTextLabel.isHidden ? 20 : 60)
        tableViewTopConstraint?.isActive = true
        
        if limitTextLabel.isHidden == true {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: 75),
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
    
    private func getCurrentDayInRussian() -> String? {
        let daysOfWeek = ["Вс", "Пн", "Вт", "Ср", "Чт", "Пт", "Сб"]
        let currentDate = Date()
        let calendar = Calendar.current
        let weekDayIndex = calendar.component(.weekday, from: currentDate) - 1
        return daysOfWeek[weekDayIndex]
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
              let selectedEmojiString = selectedEmoji, !selectedEmojiString.isEmpty
        else {
            print("Чего-то не хватает")
            return
        }
        
        guard let selectedDays = getCurrentDayInRussian() else {
            print("Не удалось получить текущий день недели")
            return
        }
        
        let tracker = Tracker(id: UUID(), name: selectedHabitName, color: selectedColorSting, emoji: selectedEmojiString, schedule: [selectedDays] )
        
        let trackerCategoryString = TrackerCategory(header: selectedCategoryString, trackers: [tracker])
        
        print("Перед вызовом делегата eventCreateDelegate: \(eventCreateDelegate != nil)")
        if let delegate = eventCreateDelegate {
            delegate.didCreateEvent(with: trackerCategoryString)
            print("Вызов делегата на создании события")
        } else {
            print("Delegate не установлен")
        }
        
        finishCreatingEventAndDismiss()
        print("✅ Новое событие c названием категории \(selectedCategoryString), названием привычки \(selectedHabitName), выбранным эмодзи \(selectedEmojiString), выбранным цветом \(selectedColorSting), и выбранными днями \(selectedDays) создана")
    }
    
    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }
}

extension NewEventViewController: UITextFieldDelegate {
    
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

extension NewEventViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryCell")
        cell.textLabel?.text = "Категория"
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = .black
        cell.detailTextLabel?.text = selectedCategory ?? ""
        cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        cell.layer.cornerRadius = 16
        cell.layer.masksToBounds = true
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        let iconImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        iconImage.image = UIImage(named: "icon_next")
        cell.accessoryView = iconImage
        
        updateCreateButtonState()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let navigationVC = CategoryViewController()
        navigationVC.categoryToPass = { [weak self]  selectedCategory in
            self?.selectedCategory = selectedCategory
            tableView.reloadRows(at: [indexPath], with: .automatic)
            print("✅ Категория \(selectedCategory) добавлена в таблицу")
        }
        navigationVC.modalPresentationStyle = .pageSheet
        present(navigationVC, animated: true)
    }
}

extension NewEventViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
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
            let cell = emojiCollection.cellForItem(at: indexPath) as! EmojiCollectionViewCell
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
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! SupplementaryView
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

