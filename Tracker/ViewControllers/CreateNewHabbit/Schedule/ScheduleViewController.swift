//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    var arrayOfIndexes = [Int]()
    var scheduleToPass: ( (String) -> Void )?
    
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
    
    private let labelHeader: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let tableViewRows = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота", "Воскресенье"]
    
    private let tableView = UITableView()
    
    private let readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        self.title = "Расписание"

        setupScrollView()
        setupContentView()
        setupLabelHeader()
        setupTableView()
        setupReadyButton()
    }
    
    func setupLabelHeader() {
        contentView.addSubview(labelHeader)
        labelHeader.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            labelHeader.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelHeader.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22),
        ])
    }
    
    func setupScrollView() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func setupContentView() {
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
//            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])
    }
    
    func setupReadyButton(){
        
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.addTarget(self, action: #selector(readyButtonDidTap), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            readyButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            readyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupTableView() {
        
        contentView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.layer.cornerRadius = 16
        tableView.backgroundView?.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        tableView.tableHeaderView = UIView()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 60),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    func appendOrRemoveArray(sender: Bool, indexPath: IndexPath) {
        
        if sender == true {
            self.arrayOfIndexes.append(indexPath.row)
        } else {
            self.arrayOfIndexes.removeAll(where: { $0 == indexPath.row })
        }
    }
    
    @objc func readyButtonDidTap(_ sender: UIButton) {
        passScheduleToCreatingTrackerVC()
        dismiss(animated: true)
    }

    
    func passScheduleToCreatingTrackerVC() {
        var result = String()
        
        if arrayOfIndexes.count == 7 {
            result = "Каждый день"
        } else {
            let daysOfWeek = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
            let arrayOfString = arrayOfIndexes.map { daysOfWeek[$0] }
            result = arrayOfString.joined(separator: ", ")
        }
        scheduleToPass?(result)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = tableViewRows[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = UIColor(named: "Light Grey")?.withAlphaComponent(0.3)
        cell.selectionStyle = .none
        
        let switchButton = UISwitch()
//        switchButton.setOn(false, animated: true)
        switchButton.onTintColor = UIColor.blue
        switchButton.addTarget(self, action: #selector(switchButtonChanged(_:)), for: .valueChanged)
        switchButton.tag = indexPath.row
        cell.accessoryView = switchButton
        
        switchButton.isOn = arrayOfIndexes.contains(indexPath.row)
        
        // Убираем сепаратор у последней ячейки
        if indexPath.row == tableViewRows.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    // настраиваем высоту ячейки
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    @objc func switchButtonChanged(_ sender: UISwitch) {
        let indexPathRow = sender.tag
        let isOn = sender.isOn
        
        if isOn {
            if !arrayOfIndexes.contains(indexPathRow) {
                arrayOfIndexes.append(indexPathRow)
            }
        } else {
            if let index = arrayOfIndexes.firstIndex(of: indexPathRow) {
                arrayOfIndexes.remove(at: index)
            }
        }
        
//        guard let cell = sender.superview as? UITableViewCell,
//        let indexPath = tableView.indexPath(for: cell) else { return }
//        let isOn = sender.isOn
//        appendOrRemoveArray(sender: isOn, indexPath: indexPath)
        print("Switch button changed")
    }
}
