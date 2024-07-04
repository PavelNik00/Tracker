//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import CoreData
import UIKit

final class TrackerViewController: UIViewController, NewHabitCreateViewControllerDelegate, NewEventCreateViewControllerDelegate {
    
    let newHabitViewController = NewHabitViewController()
    let newEventViewController = NewEventViewController()
    
    var categories: [TrackerCategory] = []
    
    var newHabit: [Tracker]
    var currentDate: Date = Date()
    
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    
    private var trackerID: UUID?
    private var selectedHabitNameString: String?
    private var selectedCategoryName: String?
    private var selectedDaysString: String?
    private var selectedColorName: UIColor?
    private var selectedEmojiString: String?
    
    private lazy var errorSearchImageView = UIImageView()
    private lazy var noSearchLabel = UILabel()
    private lazy var errorImage = UIImageView()
    private lazy var noTrackerLabel = UILabel()
    
    private let labelTrackerTitle = UILabel()
    private let searchBar = UISearchBar()
    private let datePicker = UIDatePicker()
    
    private let trackerStore = TrackerStore.shared
    private let categoryStore = TrackerCategoryStore.shared
    private let recordStore = TrackerRecordStore.shared
    
    private let dayOfWeekMapping: [String: String] = [
        "Пн" : "Monday",
        "Вт": "Tuesday",
        "Ср": "Wednesday",
        "Чт": "Thursday",
        "Пт": "Friday",
        "Сб": "Saturday",
        "Вс": "Sunday"
    ]
    
    private let trackerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
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
        
        // методы для очистки Core Data
        trackerStore.deleteAllTrackers()
        categoryStore.deleteAllCategories()
        recordStore.deleteAllRecords()
        view.backgroundColor = .white
        trackerStore.delegate = self
        
        newEventViewController.eventCreateDelegate = self
        newHabitViewController.habitCreateDelegate = self
        
        updateTrackerCategories()
        updateMadeTrackers()
        
        setupErrorImage()
        setuplabelQuestion()
        
        reloadData()
        
        setuplabelTrackerTitle()
        setupSearchBar()
        
        setupNavigationBar()
        updateView()
    }
    
    func reloadData() {
        
        let datePicker = UIDatePicker()
        datePicker.date = currentDate
        
        datePickerValueChanged(datePicker)
    }
    
    func setupNavigationBar() {
        
        let image = UIImage(named: "icon_plus")
        
        let addButton = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        navigationItem.leftBarButtonItem = addButton
        
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
        datePicker.widthAnchor.constraint(equalToConstant: 100).isActive = true
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    func didFinishCreatingHabitAndDismiss() {
        updateView()
    }
    
    func didFinishCreatingEventAndDismiss() {
        updateView()
    }
    
    func didCreateHabit(with trackerCategoryString: TrackerCategory) {
        
        selectedHabitNameString = trackerCategoryString.trackers?.first?.name
        selectedCategoryName = trackerCategoryString.header
        selectedDaysString = trackerCategoryString.trackers?.first?.schedule.joined(separator: ", ")
        selectedColorName = trackerCategoryString.trackers?.first?.color
        selectedEmojiString = trackerCategoryString.trackers?.first?.emoji
        
        if let selectedDaysString = selectedDaysString {
            let scheduleComponents = selectedDaysString.components(separatedBy: ", ")
            
            let newHabit = Tracker(id: UUID(),
                                   name: selectedHabitNameString ?? "Какое-то название :(",
                                   color: selectedColorName ?? UIColor.black,
                                   emoji: selectedEmojiString ?? "⭕️",
                                   schedule: scheduleComponents)
            
            if let categoryIndex = visibleCategories.firstIndex(where: { $0.header == selectedCategoryName }) {
                
                let category = visibleCategories[categoryIndex]
                var updateTrackerArray = category.trackers ?? []
                updateTrackerArray.append(newHabit)
                
                let updatedCategory = TrackerCategory(
                    header: category.header,
                    trackers: updateTrackerArray)
                
                visibleCategories[categoryIndex] = updatedCategory
                createTracker(newHabit, with: updatedCategory.header)
            } else {
                
                let newCategory = TrackerCategory(
                    header: selectedCategoryName ?? "Неопознанная категория :(",
                    trackers: [newHabit])
                
                visibleCategories.append(newCategory)
                createTracker(newHabit, with: newCategory.header)
            }
            trackerCollectionView.reloadData()
        }
        
        updateView()
    }
    
    func didCreateEvent(with trackerCategoryString: TrackerCategory) {
        print("didCreateEvent вызван с категорией: \(trackerCategoryString.header)")
        
        selectedHabitNameString = trackerCategoryString.trackers?.first?.name
        selectedCategoryName = trackerCategoryString.header
        selectedColorName = trackerCategoryString.trackers?.first?.color
        selectedEmojiString = trackerCategoryString.trackers?.first?.emoji
        selectedDaysString = trackerCategoryString.trackers?.first?.schedule.first
        
        if let selectedDaysString = selectedDaysString {
            
            let newEvent = Tracker(id: UUID(),
                                   name: selectedHabitNameString ?? "Какое-то название :(",
                                   color: selectedColorName ?? UIColor.black,
                                   emoji: selectedEmojiString ?? "⭕️",
                                   schedule: [selectedDaysString] )
            
            if let categoryIndex = visibleCategories.firstIndex(where: { $0.header == selectedCategoryName }) {
                
                let category = visibleCategories[categoryIndex]
                var updateTrackerArray = category.trackers ?? []
                updateTrackerArray.append(newEvent)
                
                let updatedCategory = TrackerCategory(
                    header: category.header,
                    trackers: updateTrackerArray)
                
                visibleCategories[categoryIndex] = updatedCategory
                createTracker(newEvent, with: updatedCategory.header)
            } else {
                
                let newCategory = TrackerCategory(
                    header: selectedCategoryName ?? "Неопознанная категория :(",
                    trackers: [newEvent])
                
                visibleCategories.append(newCategory)
                createTracker(newEvent, with: newCategory.header )
            }
            trackerCollectionView.reloadData()
            
            updateView()
        } else {
            print("Ошибка: не удалось получить дату из расписания")
        }
    }
    
    private func updateView() {
        if !isHabitExistsForSelectedDate() ||
            visibleCategories.isEmpty {
            errorImage.isHidden = false
            noTrackerLabel.isHidden = false
            trackerCollectionView.isHidden = true
        } else {
            errorImage.isHidden = true
            noTrackerLabel.isHidden = true
            setupTrackerCollectionView()
            trackerCollectionView.isHidden = false
        }
        trackerCollectionView.reloadData()
    }
    
    private func removeErrorImageAndLabelQuestion() {
        errorImage.removeFromSuperview()
        noTrackerLabel.removeFromSuperview()
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
    
    private func setupNoSearchImage() {
        errorSearchImageView.image = UIImage(named: "icon_search_error")
        errorSearchImageView.translatesAutoresizingMaskIntoConstraints = false
        errorSearchImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        errorSearchImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        errorSearchImageView.clipsToBounds = true
        
        view.addSubview(errorSearchImageView)
        errorSearchImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorSearchImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    private func setuplabelQuestion() {
        noTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        noTrackerLabel.text = "Что будем отслеживать?"
        noTrackerLabel.font = .systemFont(ofSize: 12)
        noTrackerLabel.sizeToFit()
        noTrackerLabel.textAlignment = .center
        
        view.addSubview(noTrackerLabel)
        noTrackerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noTrackerLabel.topAnchor.constraint(equalTo: errorImage.bottomAnchor, constant: 8).isActive = true
    }
    
    private func setupNoSearchLabel() {
        noSearchLabel.translatesAutoresizingMaskIntoConstraints = false
        noSearchLabel.text = "Ничего не найдено"
        noSearchLabel.font = .systemFont(ofSize: 12)
        noSearchLabel.sizeToFit()
        noSearchLabel.textAlignment = .center
        
        view.addSubview(noSearchLabel)
        noSearchLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noSearchLabel.topAnchor.constraint(equalTo: errorSearchImageView.bottomAnchor, constant: 8).isActive = true
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
    
    private func setupTrackerCollectionView() {
        view.addSubview(trackerCollectionView)
        trackerCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let layout = trackerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout?.headerReferenceSize = CGSize(width: trackerCollectionView.frame.width, height: 50)
        
        trackerCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        trackerCollectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        trackerCollectionView.register(TrackerCollectionSupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 190),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updateTrackerCategories() {
        categories = categoryStore.categories
        trackerCollectionView.reloadData()
        print("✅ Обновление категории трекеров \(categories)")
    }
    
    private func updateMadeTrackers() {
        if let records = recordStore.records {
            self.completedTrackers = records
            print("✅ Обновление записи трекеров \(records)")
        } else {
            self.completedTrackers = []
            print("❗️Трекер \(completedTrackers) не добавлен в запись")
        }
    }
    
    private func reloadVisibleCategories() {
        
        let currentDate = datePicker.date
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDate)
        
        let filterWeekdayString = dayOfWeekMapping.first { $0.value == calendar.weekdaySymbols[filterWeekday - 1] }?.key
        
        guard let filterWeekdayString = filterWeekdayString else {
            print("Ошибка преобразования дня недели")
            return
        }
        
        let filterText = (searchBar.text ?? "").lowercased()
        visibleCategories = categories.compactMap { category in
            guard let trackers = category.trackers else { return nil }
            
            let filteredTrackers = trackers.filter { tracker in
                let textCondition = filterText.isEmpty || tracker.name.lowercased().contains(filterText)
                
                let dateCondition = tracker.schedule.contains (filterWeekdayString)
                
                return textCondition && dateCondition
            }
            
            return filteredTrackers.isEmpty ? nil : TrackerCategory(
                header: category.header,
                trackers: trackers)
            
        }
        updateView()
        print("✅ Перезагрузка созданных категорий \(visibleCategories)")
    }
    
    private func isHabitExistsForSelectedDate() -> Bool {
        for category in visibleCategories {
            if let trackers = category.trackers {
                for tracker in trackers {
                    let scheduleComponents = tracker.schedule
                    let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
                    let weekDaySymbols = Calendar.current.weekdaySymbols
                    let selectedDayName = weekDaySymbols[dayOfWeek - 1]
                    
                    let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0]}
                    if englishScheduleComponents.contains(selectedDayName) {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDateNew = sender.date
        currentDate = selectedDateNew
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        updateView()
        reloadVisibleCategories()
    }
    
    @objc func addButtonTapped() {
        let addNewVC = ChooseTypeOfTrackerVC()
        addNewVC.habitCreateDelegate = self
        addNewVC.eventCreateDelegate = self
        let addNavigationController = UINavigationController(rootViewController: addNewVC)
        addNavigationController.modalPresentationStyle = .pageSheet
        present(addNavigationController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension TrackerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let category = visibleCategories[section]
        
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            print("Фильтруем трекер с расписанием: \(scheduleComponents) для дня: \(selectedDayName)")
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        let count = filterTrackers?.count ?? 0
        
        print("Количество трекеров в секции \(section): \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell else {
            print("Ошибка: Не удалось создать ячейку TrackerCollectionViewCell")
            return UICollectionViewCell()
        }
        
        cell.delegate = self
        let cellData = visibleCategories[indexPath.section]
        guard cellData.trackers?[indexPath.row] != nil else { return UICollectionViewCell() }
        
        let filterTrackers = cellData.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            print("Фильтруем трекер с расписанием: \(scheduleComponents) для дня: \(selectedDayName)")
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        if let tracker = filterTrackers?[indexPath.row] {
            
            let isCompletedToday = isTrackerCompletedToday(id: tracker.id, at: indexPath)
            
            let completedDays = getCompletedDaysCount(for: tracker)
            
            cell.configure(with: tracker,
                           isCompletedToday: isCompletedToday,
                           completedDays: completedDays,
                           indexPath: indexPath
            )
        } else {
            print("Проблема с отображением ячейки")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? TrackerCollectionSupplementaryView else {
            print("Ошибка: Не удалось создать заголовок TrackerCollectionSupplementaryView")
            return UICollectionReusableView()
        }
        
        let category = visibleCategories[indexPath.section]
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            print("Фильтруем трекер с расписанием: \(scheduleComponents) для дня: \(selectedDayName)")
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        if filterTrackers?.isEmpty == false  {
            header.titleLabel.text = visibleCategories[indexPath.section].header
        } else {
            header.titleLabel.text = nil
        }
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: (collectionView.bounds.width / 2) - 5, height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let category = visibleCategories[section]
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        if filterTrackers?.isEmpty == false {
            return CGSize(width: collectionView.bounds.width, height: 50)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 0)
        }
    }
    
    private func getCompletedDaysCount(for tracker: Tracker) -> Int {
        return completedTrackers.filter { $0.id == tracker.id }.count
    }
    
    private func isTrackerCompletedToday(id: UUID, at indexPath: IndexPath) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        print("выполнена проверка на соответсвте id и даты")
        return trackerRecord.id == id && isSameDay
    }
    
    func createTracker(_ tracker: Tracker, with categoryName: String) {
        do {
            if let categoryFromCoreData = try categoryStore.fetchTrackerCategoryCoreData(title: categoryName) {
                print("✅ Категория найдена в Core Data")
                let newTracker = try trackerStore.addCoreDataTracker(tracker, with: categoryFromCoreData)
                
                updateView()
                
                print("✅ Добавлен новый трекер в Core Data с трекером \(tracker) и категорией \(categoryFromCoreData)")
            } else {
                print("Категория не найдена в Core Data")
            }
        } catch {
            print("Невозможно создать трекер")
        }
    }
}

// MARK: - TrackerCollectionViewCellDelegate

extension TrackerViewController: TrackerCollectionViewCellDelegate {
    
    func completedTracker(id: UUID, at indexPath: IndexPath) {
        
        let newRecord = TrackerRecord(id: id, date: currentDate)
        completedTrackers.append(newRecord)
        do {
            try trackerStore.trackerUpdate(newRecord)
        } catch {
            print("Ошибка при обновлении хранилища трекеров: \(error)")
        }
        
        trackerCollectionView.reloadItems(at: [indexPath])
    }
    
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        
        let calendar = Calendar.current
        if let index = completedTrackers.firstIndex(where: { $0.id == id && calendar.isDate($0.date, inSameDayAs: currentDate) }) {
            let recordToDelete = completedTrackers[index]
            completedTrackers.remove(at: index)
            
            do {
                try TrackerRecordStore.shared.removeRecordCoreData(id, with: currentDate)
                print("Попытка удалить трекер с \(id) и датой \(currentDate)")
            } catch {
                print("Ошибка при удалении трекера из хранилища: \(error)")
            }
            
            trackerCollectionView.reloadItems(at: [indexPath])
        } else {
            print("Запись с id \(id) и датой \(currentDate) не найдена")
        }
    }
}

// MARK: - TrackerStoreDelegate

extension TrackerViewController: TrackerStoreDelegate {
    func trackerStoreDidUpdate() {
        updateTrackerCategories()
        updateMadeTrackers()
        reloadVisibleCategories()
    }
}

