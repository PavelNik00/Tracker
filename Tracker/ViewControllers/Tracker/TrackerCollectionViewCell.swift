//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 29.05.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    var trackerCellView = UIView()
    
    var titleLabel = UILabel()
    var emojiLabel = UILabel()
    var emojiLabelBG = UIButton()
    var dayLabel = UILabel()
    var plusButton = UIButton()
    
    var buttonTapped: (() -> Void)?
    
    var days = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTrackeCellView()
        setupNameLabel()
        setupEmojiLabelBG()
        setupEmojiLabel()
        setupDayLabel()
        setupDoneButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupTrackeCellView() {
        contentView.addSubview(trackerCellView)
        trackerCellView.translatesAutoresizingMaskIntoConstraints = false
        trackerCellView.layer.cornerRadius = 16
        trackerCellView.layer.masksToBounds = true
        trackerCellView.backgroundColor = .black
        
        NSLayoutConstraint.activate([
            trackerCellView.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerCellView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    func setupNameLabel() {
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: trackerCellView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerCellView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: trackerCellView.topAnchor, constant: 44),
            titleLabel.bottomAnchor.constraint(equalTo: trackerCellView.bottomAnchor, constant: -12)
        ])
    }
    
    func setupEmojiLabelBG() {
        contentView.addSubview(emojiLabelBG)
        emojiLabelBG.translatesAutoresizingMaskIntoConstraints = false
//        emojiLabelBG.frame.size = CGSize(width: 24, height: 24)
//        emojiLabelBG.layer.cornerRadius = frame.size.width / 2
//        emojiLabelBG.layer.masksToBounds = true
//        emojiLabelBG.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabelBG.setImage(UIImage(named: "icon_emojiBG"), for: .normal)
        emojiLabelBG.isEnabled = false
        
        NSLayoutConstraint.activate([
            emojiLabelBG.leadingAnchor.constraint(equalTo: trackerCellView.leadingAnchor, constant: 12),
            emojiLabelBG.topAnchor.constraint(equalTo: trackerCellView.topAnchor, constant: 12),
            emojiLabelBG.heightAnchor.constraint(equalToConstant: 24),
            emojiLabelBG.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func setupEmojiLabel() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
//        emojiLabel.layer.cornerRadius = 0
//        emojiLabel.layer.masksToBounds = true
//        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.font = .systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
//            emojiLabel.leadingAnchor.constraint(equalTo: trackerCellView.leadingAnchor, constant: 12),
//            emojiLabel.topAnchor.constraint(equalTo: trackerCellView.topAnchor, constant: 12),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiLabelBG.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiLabelBG.centerYAnchor)
//            emojiLabel.heightAnchor.constraint(equalToConstant: 12),
//            emojiLabel.widthAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    func setupDayLabel() {
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.text = "\(days) дней"
        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dayLabel.textColor = .black
        dayLabel.textAlignment = .left
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: trackerCellView.bottomAnchor, constant: 16),
            dayLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    func setupDoneButton() {
        contentView.addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
//        plusButton.layer.cornerRadius = 68
//        plusButton.layer.masksToBounds = true
//        plusButton.backgroundColor = .black
        plusButton.setImage(UIImage(systemName: "icon_button_black"), for: .normal)
//        plusButton.setTitle("+", for: .normal)
//        plusButton.setTitleColor(.white, for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: trackerCellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trackerCellView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    @objc func plusButtonTapped() {
        buttonTapped?()
        print("Нажата клавиша +")
    }
    
}
