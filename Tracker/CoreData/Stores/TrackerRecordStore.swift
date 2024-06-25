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
        try? getTrackerRecords() ?? []
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
    
    // создание новой записи в Core Data 
    func createCoreDataTrackerRecord(from record: TrackerRecord) -> TrackerRecordCoreData {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.date = record.date
        newTrackerRecord.id = record.id
        return newTrackerRecord
    }
    
    // удаление записи из Core Data
    func removeRecordCoreData(_ id: UUID, with date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        let trackerRecords = try context.fetch(request)
        let filterRecord = trackerRecords.first {
            $0.id == id && $0.date == date
        }
        if let trackerRecordCoreData = filterRecord {
            context.delete(trackerRecordCoreData)
            try saveContext()
        }
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
    
    // Получение всех записей
    private func getTrackerRecords() throws -> [TrackerRecord]? {
        let request = TrackerRecordCoreData.fetchRequest()
        let objects = try context.fetch(request)
        let records = try objects.map { try self.createNewRecord($0) }
        return records
    }
    
    // Преобразование объекта Core Data в объект TrackerRecord
    private func createNewRecord(_ recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = recordCoreData.id,
            let date = recordCoreData.date else {
            throw fatalError("Ошибка в получение id или data")
        }
        let trackerRecord = TrackerRecord(id: id, date: date)
        return trackerRecord
    }
}
