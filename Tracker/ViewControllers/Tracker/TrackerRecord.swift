//
//  TrackerRecord.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 16.05.2024.
//

import Foundation

// сущность для хранения записи о том, что некий трекер был выполнен на некоторую дату
struct TrackerRecord {
    let id: UUID
    let date: Date
}
