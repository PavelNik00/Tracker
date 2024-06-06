//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 29.05.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func completedTracker(id: UUID, at indexPath: IndexPath) // кнопка завершения
    func uncompletedTracker(id: UUID, at indexPath: IndexPath) // кнопка галочки
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // делегат для обработки нажатия кнопки в ячейке
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    var trackerCellView = UIView()
    
    var titleLabel = UILabel()
    var emojiLabel = UILabel()
    var emojiLabelBG = UIButton()
    var dayLabel = UILabel()
    var plusButton = UIButton()
    
    var remainder10: Int = 0
    var tracker: [Tracker] = []
    
    private var isCompletedToday: Bool = false
    private var trackerId: UUID?
    private var indexPath: IndexPath?
    
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
        emojiLabel.font = .systemFont(ofSize: 12)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiLabelBG.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiLabelBG.centerYAnchor)
        ])
    }
    
    func setupDayLabel() {
        contentView.addSubview(dayLabel)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
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
        plusButton.layer.cornerRadius = 17
        plusButton.layer.masksToBounds = true
        plusButton.setImage(UIImage(systemName: "icon_button_black"), for: .normal)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            plusButton.topAnchor.constraint(equalTo: trackerCellView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: trackerCellView.trailingAnchor, constant: -12),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // метод для создания ячейки
    func configure(with tracker: Tracker,
                   isCompletedToday: Bool,
                   completedDays: Int,
                   indexPath: IndexPath
    ) {
        self.isCompletedToday = isCompletedToday
        self.trackerId = tracker.id // присваиваем id для ячейки
        self.indexPath = indexPath // присваиваем индекспас
        
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        trackerCellView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        let wordDay = pluralizeDays(completedDays)
        dayLabel.text = "\(wordDay)"
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        
        let image = isCompletedToday ? UIImage(named: "icon_done_white") : UIImage(named: "icon_plus_white")
        plusButton.setImage(image, for: .normal)
        plusButton.alpha = isCompletedToday ? 0.3 : 1.0
    }
    
    private func pluralizeDays(_ count: Int) -> String {
        let remainder100 = count % 100
        
        if remainder100 == 1 && remainder100 != 11 {
            return "\(count) день"
        } else if remainder100 >= 2 && remainder100 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(count) дня"
        } else {
            return "\(count) дней"
        }
    }
    
    // обработка нажатия на кнопку "+"
    @objc func plusButtonTapped() {
        guard let trackerId = trackerId,
                let indexPath = indexPath
        else {
            assertionFailure("no trackerID")
            return }
    
        if isCompletedToday {
            delegate?.uncompletedTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completedTracker(id: trackerId, at: indexPath)
        }
        print("Нажата клавиша +")
    }
    
}
