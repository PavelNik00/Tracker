//
//  StatisticController.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 08.04.2024.
//

import UIKit

class StatisticViewController: UIViewController {
    
    let labelStatisticTitle = UILabel()
    let noStatisticImage = UIImageView()
    let labelQuestion = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupStatisticTitle()
        setupNoStatisticImage()
        setupLabelQuestion()
    }
    
    func setupStatisticTitle() {
        labelStatisticTitle.translatesAutoresizingMaskIntoConstraints = false
        labelStatisticTitle.font = .boldSystemFont(ofSize: 34)
        labelStatisticTitle.text = "Статистика"
        labelStatisticTitle.textColor = .black
        labelStatisticTitle.textAlignment = .left
        
        view.addSubview(labelStatisticTitle)
        labelStatisticTitle.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        labelStatisticTitle.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    }
    
    func setupNoStatisticImage() {
        noStatisticImage.image = UIImage(named: "icon_statistic_error")
        noStatisticImage.translatesAutoresizingMaskIntoConstraints = false
        noStatisticImage.heightAnchor.constraint(equalToConstant: 80).isActive = true
        noStatisticImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        noStatisticImage.clipsToBounds = true 

        view.addSubview(noStatisticImage)
        noStatisticImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        noStatisticImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    func setupLabelQuestion() {
        labelQuestion.translatesAutoresizingMaskIntoConstraints = false
        labelQuestion.font = .systemFont(ofSize: 12)
        labelQuestion.text = "Анализировать пока нечего"
        labelQuestion.textAlignment = .center
        labelQuestion.textColor = .black
        
        view.addSubview(labelQuestion)
        labelQuestion.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        labelQuestion.topAnchor.constraint(equalTo: noStatisticImage.bottomAnchor, constant: 8).isActive = true
    }
}
