//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 03.04.2024.
//

import UIKit

class TrackerViewController: UIViewController {
    
    // список категорий и вложенных в них трекеров
    var categories: [TrackerCategory] = []
    
    // трекеры, которые были выполнены в выбранную дату хранятся здесь
    var completedTrackers: [TrackerRecord] = []
    
    let errorImage = UIImageView()
    let labelQuestion = UILabel()
    let labelTrackerTitle = UILabel()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupErrorImage()
        setuplabelQuestion()
        setuplabelTrackerTitle()
        setupSearchBar()
        
        setupNavigationBar()
        setupDatePicker()
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
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
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
    
    @objc func addButtonTapped() {
        print("Add button tapped")
    }
}

