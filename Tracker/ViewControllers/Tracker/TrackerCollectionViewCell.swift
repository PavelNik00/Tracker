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
    var dayLabel = UILabel()
    var plusButton = UIButton()
    
    var days = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupTrackeCellView()
        setupNameLabel()
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
    
    func setupEmojiLabel() {
        contentView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        emojiLabel.layer.cornerRadius = emojiLabel.frame.width / 2
        emojiLabel.layer.masksToBounds = true
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.font = .systemFont(ofSize: 16)
        
        NSLayoutConstraint.activate([
            emojiLabel.leadingAnchor.constraint(equalTo: trackerCellView.leadingAnchor, constant: 12),
            emojiLabel.topAnchor.constraint(equalTo: trackerCellView.topAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24)
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
        plusButton.layer.cornerRadius = plusButton.frame.width / 2
        plusButton.layer.masksToBounds = true
        plusButton.backgroundColor = .black
        plusButton.setImage(UIImage(systemName: "icon_plus"), for: .normal)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: trackerCellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trackerCellView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
}
