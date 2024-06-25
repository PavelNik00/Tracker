//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    
    // Синглтон для хранилища записей
    static let shared = TrackerRecordStore()
    
    // Список записей, получаемых из Core Data
    var records: [TrackerRecord]? {
        return []
    }
    
    // Контекст Core Data
    private let context: NSManagedObjectContext

    // получаем контекст из AppDelegate
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    // Инициализатор
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // Сохранение изменений в контексте Core Data
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
}
