//
//  CategoryCell.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 23.05.2024.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    let categoryLabel = UILabel()
    let checkmarkImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(checkmarkImage)
        addSubview(categoryLabel)
        
        self.heightAnchor.constraint(equalToConstant: 75).isActive = true
        
        categoryLabel.font = .systemFont(ofSize: 17, weight: .regular)
        categoryLabel.textColor = .black
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        checkmarkImage.isHidden = true
        checkmarkImage.image = UIImage(named: "icon_done")
        checkmarkImage.contentMode = .center
        checkmarkImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            checkmarkImage.centerYAnchor.constraint(equalTo: centerYAnchor),
            checkmarkImage.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
