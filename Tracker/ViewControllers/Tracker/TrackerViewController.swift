//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import UIKit

final class TrackerViewController: UIViewController, NewHabitCreateViewControllerDelegate {
    
    // список категорий и вложенных в них трекеров
    var categories: [TrackerCategory] = []
    var newHabit: [Tracker]
    
    // трекеры, которые были выполнены в выбранную дату хранятся здесь
    var completedTrackers: [TrackerRecord] = []
    var completedDaysCount: Int = 0
    
    var isCompleted: Bool?
    var trackerID: UUID?
    
    var selectedHabitNameString: String?
    var selectedCategoryName: String?
    var selectedDaysString: String?
    var selectedColorName: UIColor?
    var selectedEmojiString: String?
    
    let datePicker = UIDatePicker()
    lazy var currentDate = datePicker.date
    
    let errorImage = UIImageView()
    let labelQuestion = UILabel()
    let labelTrackerTitle = UILabel()
    let searchBar = UISearchBar()
    
    let newHabitViewController = NewHabitViewController()
    
    let trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.headerReferenceSize = CGSize(width: 100, height: 50)
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    
    init(categories: [TrackerCategory], completedTrackers: [TrackerRecord], newCategories: [Tracker]) {
        self.categories = categories
        self.newHabit = newCategories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.categories = []
        self.completedTrackers = []
        self.newHabit = []
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        newHabitViewController.habitCreateDelegate = self
//        setupErrorImage()
//        setuplabelQuestion()
        
        setuplabelTrackerTitle()
        setupSearchBar()
        
        updateView()
        
        setupNavigationBar()
        setupDatePicker()
    }
    
    private func updateView() {
        if categories.isEmpty {
            setupErrorImage()
            setuplabelQuestion()
            print("Загрузка картинки и рыбы-текста")
        } else if selectedHabitNameString != nil {
            setupTrackerCollectionView()
            print("Загрузка коллекциивьб")
        }
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
    
    private func setuplabelQuestion() {
        labelQuestion.translatesAutoresizingMaskIntoConstraints = false
        labelQuestion.text = "Что будем отслеживать?"
        labelQuestion.font = .systemFont(ofSize: 12)
        labelQuestion.sizeToFit()
        labelQuestion.textAlignment = .center
        
        view.addSubview(labelQuestion)
        labelQuestion.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        labelQuestion.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setuplabelTrackerTitle() {
        labelTrackerTitle.translatesAutoresizingMaskIntoConstraints = false
        labelTrackerTitle.text = "Трекеры"
        labelTrackerTitle.font = .boldSystemFont(ofSize: 34)
        labelTrackerTitle.sizeToFit()
        labelTrackerTitle.textAlignment = .left
        
        view.addSubview(labelTrackerTitle)
        labelTrackerTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        labelTrackerTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    func setupNavigationBar() {
        let image = UIImage(named: "icon_plus")
        
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
    }
    
    func setupDatePicker() {
        let datePicker = UIDatePicker()
        
        let currentDate = Date()
        let calendar = Calendar.current
        let minDate = calendar.date(byAdding: .year, value: -10, to: currentDate)
        let maxDate = calendar.date(byAdding: .year, value: 10, to: currentDate)
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.calendar.locale = Locale(identifier: "ru_RU")
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.widthAnchor.constraint(equalToConstant: 120).isActive = true
//        datePicker.tintColor = UIColor(named: "Blue")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func setupSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = "Поиск"
        searchBar.barTintColor = UIColor(red: 118, green: 118, blue: 128, alpha: 0.12)

        view.addSubview(searchBar)
        searchBar.topAnchor.constraint(equalTo: labelTrackerTitle.bottomAnchor, constant: 8).isActive = true
        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
    }
    
    func setupTrackerCollectionView() {
        view.addSubview(trackerCollectionView)
        trackerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = trackerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout?.headerReferenceSize = CGSize(width: trackerCollectionView.frame.width, height: 50)
        
        trackerCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        trackerCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        trackerCollectionView.register(TrackerCollectionSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        trackerCollectionView.backgroundColor = .lightGrey
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc func addButtonTapped() {
        let addNewVC = ChooseTypeOfTrackerVC()
        addNewVC.habitCreateDelegate = self
        let addNavigationController = UINavigationController(rootViewController: addNewVC)
        addNavigationController.modalPresentationStyle = .pageSheet
        present(addNavigationController, animated: true)
        print("Нажата клавиша создания привычки или события")
    }
    

    func didFinishCreatingHabitAndDismiss() {
        updateView()
        print("Вызов делегата на трекерконтролере")
    }
    
    func didCreateHabit(with trackerCategoryString: TrackerCategory) {
        
        selectedHabitNameString = trackerCategoryString.trackers?.first?.name
        selectedCategoryName = trackerCategoryString.header
        selectedDaysString = trackerCategoryString.trackers?.first?.schedule
        selectedColorName = trackerCategoryString.trackers?.first?.color
        selectedEmojiString = trackerCategoryString.trackers?.first?.emoji
        
        if let categoryIndex = categories.firstIndex(where: { $0.header == selectedCategoryName }) {
            
            let category = categories[categoryIndex]
            let newHabit = Tracker(id: UUID(),
                                   name: selectedHabitNameString ?? "Какое-то название :(",
                                   color: selectedColorName ?? UIColor.black,
                                   emoji: selectedEmojiString ?? "⭕️",
                                   schedule: selectedDaysString ?? "???")
            
            var updateTrackerArray = category.trackers ?? []
            updateTrackerArray.append(newHabit)
            
            let updatedCategory = TrackerCategory(
                header: category.header,
                trackers: updateTrackerArray)
            
            categories[categoryIndex] = updatedCategory
            
        } else {
            
            let newHabit = Tracker(
                id: UUID(),
                name: selectedHabitNameString ?? "Какое-то название :(",
                color: selectedColorName ?? UIColor.black,
                emoji: selectedEmojiString ?? "⭕️",
                schedule: selectedDaysString ?? "???")
            
            let newCategory = TrackerCategory(
                header: selectedCategoryName ?? "Неопознанная категория :(",
                trackers: [newHabit])
            
            categories.append(newCategory)
        }
        trackerCollectionView.reloadData()
        updateView()
        print("Сработал делегат на TrackerVC")
    }
}

// настройка коллекции
extension TrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    // количество ячеек
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = categories[section]
        return category.trackers?.count ?? 0
    }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        let category = categories[indexPath.section]
        
        if let tracker = category.trackers?[indexPath.item] {
            var isChecked = completedTrackers.contains { $0.id == tracker.id }
            
            cell.titleLabel.text = tracker.name
            cell.emojiLabel.text = tracker.emoji
            cell.trackerCellView.backgroundColor = tracker.color
            cell.dayLabel.text = isChecked ? "1" : "0"
            cell.alpha = isChecked ? 0.3 : 1.0
//            cell.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
            
            let image = isChecked ? UIImage(named: "icon_done_white") : UIImage(named: "icon_button_plus")
            cell.plusButton.setImage(image, for: .normal)
            cell.plusButton.tintColor = tracker.color.withAlphaComponent(isChecked ? 0.3 : 1.0)
            
            let today = Date()
            cell.plusButton.isEnabled = currentDate > today ? false : true
            
            cell.buttonTapped = { [weak self] in
                guard let self = self else { return }
                if let index = self.completedTrackers.firstIndex(where: { $0.id == tracker.id }) {
                    self.completedTrackers.remove(at: index)
                } else {
                    self.completedTrackers.append(TrackerRecord(id: tracker.id, date: Date()))
                }
                collectionView.reloadData()
            }
            
        }
        collectionView.reloadData()
        print("Добавлена ячейка в таблицу")
        return cell
    }
    
    // настраиваем саплиментаривью(название категории)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! TrackerCollectionSupplementaryView
        
        header.titleLabel.text = categories[indexPath.section].header
        return header
    }
    
    // настройка размера ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.width / 2) - 15, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    // настраиваем размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
//        let indexPath = IndexPath(row: 0, section: section)
//        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
//        
//        return headerView.systemLayoutSizeFitting(
//            CGSize(width: collectionView.frame.width,
//                height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
}

