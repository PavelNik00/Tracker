//
//  TrackerCategory.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 16.05.2024.
//

import Foundation

// сущность для хранения трекеров по категориям
struct TrackerCategory {
    let header: String
    let trackers: [Tracker]?
    
    init(header: String, trackers: [Tracker]?) {
        self.header = header
        self.trackers = trackers
    }
}
