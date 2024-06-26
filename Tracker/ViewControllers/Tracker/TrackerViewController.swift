//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import UIKit

final class TrackerViewController: UIViewController, NewHabitCreateViewControllerDelegate, NewEventCreateViewControllerDelegate {
    
    let newHabitViewController = NewHabitViewController()
    let newEventViewController = NewEventViewController()
    
    // список категорий и вложенных в них трекеров
    var categories: [TrackerCategory] = []
    var newHabit: [Tracker]
    var currentDate: Date = Date()
    
    // трекеры, которые были выполнены в выбранную дату хранятся здесь
    var completedTrackers: [TrackerRecord] = []
    
    private var trackerID: UUID?
    private var selectedHabitNameString: String?
    private var selectedCategoryName: String?
    private var selectedDaysString: String?
    private var selectedColorName: UIColor?
    private var selectedEmojiString: String?
    
    private let datePicker = UIDatePicker()
    private let errorImage = UIImageView()
    private let labelQuestion = UILabel()
    private let labelTrackerTitle = UILabel()
    private let searchBar = UISearchBar()
    
    // массив для преобразования полученной даты из rus в eng
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
        
        view.backgroundColor = .white
        
        newEventViewController.eventCreateDelegate = self
        newHabitViewController.habitCreateDelegate = self
        
        setuplabelTrackerTitle()
        setupSearchBar()
        
        updateView()
        
        setupNavigationBar()
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
        print("Вызов делегата на трекерконтролере для привычки")
    }
    
    func didFinishCreatingEventAndDismiss() {
        updateView()
        print("Вызов делегата на трекерконтролере для события")
    }
    
    // метод для получения данных из NewHabitVC
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
            
            if let categoryIndex = categories.firstIndex(where: { $0.header == selectedCategoryName }) {
                
                let category = categories[categoryIndex]
                var updateTrackerArray = category.trackers ?? []
                updateTrackerArray.append(newHabit)
                
                let updatedCategory = TrackerCategory(
                    header: category.header,
                    trackers: updateTrackerArray)
                
                categories[categoryIndex] = updatedCategory
                
            } else {
                
                let newCategory = TrackerCategory(
                    header: selectedCategoryName ?? "Неопознанная категория :(",
                    trackers: [newHabit])
                
                categories.append(newCategory)
            }
            trackerCollectionView.reloadData()
        }
        
        updateView()
        print("Добавлена новая категория в TrackerCategory")
        print("Сработал делегат на TrackerVC для привычки")
    }
    
    // метод для получения данных из NewEventVC
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
            
            if let categoryIndex = categories.firstIndex(where: { $0.header == selectedCategoryName }) {
                
                let category = categories[categoryIndex]
                var updateTrackerArray = category.trackers ?? []
                updateTrackerArray.append(newEvent)
                
                let updatedCategory = TrackerCategory(
                    header: category.header,
                    trackers: updateTrackerArray)
                
                categories[categoryIndex] = updatedCategory
                
            } else {
                
                let newCategory = TrackerCategory(
                    header: selectedCategoryName ?? "Неопознанная категория :(",
                    trackers: [newEvent])
                
                categories.append(newCategory)
            }
            trackerCollectionView.reloadData()
            
            updateView()
            print("Добавлена новое событие в TrackerCategory")
            print("Сработал делегат на TrackerVC для события")
        } else {
            print("Ошибка: не удалось получить дату из расписания")
        }
    }
    
    private func updateView() {
        if !isHabitExistsForSelectedDate() {
            setupErrorImage()
            setuplabelQuestion()
            print("Загрузка картинки и рыбы-текста")
        } else {
            removeErrorImageAndLabelQuestion()
            setupTrackerCollectionView()
            //            trackerCollectionView.reloadData()
            print("Загрузка коллекции")
        }
        trackerCollectionView.reloadData()
    }
    
    private func removeErrorImageAndLabelQuestion() {
        errorImage.removeFromSuperview()
        labelQuestion.removeFromSuperview()
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
        
        // trackerCollectionView.backgroundColor = .lightGrey
        trackerCollectionView.delegate = self
        trackerCollectionView.dataSource = self
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // метод для обновления ячейки, есть ли привычка для выбранного дня или нет. Используется для обновления UI - отображения заглушки/коллекции
    private func isHabitExistsForSelectedDate() -> Bool {
        for category in categories {
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
        
        if isHabitExistsForSelectedDate() {
            removeErrorImageAndLabelQuestion()
        }
        
        updateView()
        print("Выбранная дата: \(formattedDate)")
    }
    
    @objc func addButtonTapped() {
        let addNewVC = ChooseTypeOfTrackerVC()
        addNewVC.habitCreateDelegate = self
        addNewVC.eventCreateDelegate = self
        let addNavigationController = UINavigationController(rootViewController: addNewVC)
        addNavigationController.modalPresentationStyle = .pageSheet
        present(addNavigationController, animated: true)
        print("Нажата клавиша создания привычки или события")
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
        
        // метод для фильтрации трекеров по дням недели
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            // Преобразуем расписание на русском в английские дни недели
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            print("Фильтруем трекер с расписанием: \(scheduleComponents) для дня: \(selectedDayName)")
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        let count = filterTrackers?.count ?? 0
        
        print("Количество трекеров в секции \(section): \(count)")
        return count
    }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as! TrackerCollectionViewCell
        
        
        cell.delegate = self
        let cellData = categories[indexPath.section]
        guard let tracker = cellData.trackers?[indexPath.row] else { return UICollectionViewCell() }
        
        // метод для фильтрации трекеров по дням недели
        let filterTrackers = cellData.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            // Преобразуем расписание на русском в английские дни недели
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
            print("Конфигурация ячейки для трекера: \(tracker.name)")
        } else {
            print("Проблема с отображением ячейки")
        }
        
        return cell
    }
    
    // настраиваем саплиментаривью(название категории)
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as! TrackerCollectionSupplementaryView
        
        let category = categories[indexPath.section]
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            // Преобразуем расписание на русском в английские дни недели
            let englishScheduleComponents = scheduleComponents.compactMap { dayOfWeekMapping[$0] }
            print("Фильтруем трекер с расписанием: \(scheduleComponents) для дня: \(selectedDayName)")
            return englishScheduleComponents.contains(selectedDayName)
        }
        
        if filterTrackers?.isEmpty == false  {
            header.titleLabel.text = categories[indexPath.section].header
        } else {
            header.titleLabel.text = nil
        }
        
        return header
    }
    
    // настройка размера ячейки
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
    
    // настраиваем размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let category = categories[section]
        let filterTrackers = category.trackers?.filter { tracker in
            let scheduleComponents = tracker.schedule
            let dayOfWeek = Calendar.current.component(.weekday, from: currentDate)
            let weekDaySymbols = Calendar.current.weekdaySymbols
            let selectedDayName = weekDaySymbols[dayOfWeek - 1]
            
            // Преобразуем расписание на русском в английские дни недели
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
    
    // метод для вычисления завершен ли трекер сегодня или нет
    private func isTrackerCompletedToday(id: UUID, at indexPath: IndexPath) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(trackerRecord: TrackerRecord, id: UUID) -> Bool {
        // проверка по дню, не учитывая время
        let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: currentDate)
        print("выполнена проверка на соответсвте id и даты")
        return trackerRecord.id == id && isSameDay
    }
}

// вызов делегата при нажатии на кнопку
extension TrackerViewController: TrackerCollectionViewCellDelegate {
    
    // метод для завершения трекера
    func completedTracker(id: UUID, at indexPath: IndexPath) {
        let trackerRecord = TrackerRecord(id: id, date: currentDate)
        completedTrackers.append(trackerRecord) // добавиление в хранилище записей
        
        // обновление для одной ячейки
        trackerCollectionView.reloadItems(at: [indexPath])
        print("Добавление \(id) в хранилище записей")
    }
    
    // метод для отмены завершения трекера
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) {
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord: trackerRecord, id: id)
        }
        trackerCollectionView.reloadItems(at: [indexPath])
        print("Удаление \(id) из хранилища записей")
        
    }
}
