//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 16.05.2024.
//

import Foundation

// сущность для хранения информации про трекер (привычка или нерегулярного события)
struct Tracker {
    let id: UUID
    let name: String
    let color: String
    let emoji: String
    let schedule: String
}
