//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 16.05.2024.
//

import UIKit

// сущность для хранения информации про трекер (привычка или нерегулярного события)
struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: String
    
    init(id: UUID, name: String, color: UIColor, emoji: String, schedule: String) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.schedule = schedule
    }
}
