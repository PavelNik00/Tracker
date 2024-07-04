//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import CoreData
import UIKit

final class TrackerRecordStore: NSObject {
    
    static let shared = TrackerRecordStore()
    
    var records: [TrackerRecord]? {
        do {
            return try getTrackerRecords() ?? []
        } catch {
            print("Ошибка при получении записей: \(error)")
            return nil
        }
    }
    
    private let context: NSManagedObjectContext
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func createCoreDataTrackerRecord(from record: TrackerRecord) -> TrackerRecordCoreData {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        newTrackerRecord.date = record.date
        newTrackerRecord.identifier = record.id
        print("✅ Создан новый \(newTrackerRecord) для записи c id \(record.id) и датой \(record.date)")
        return newTrackerRecord
    }
    
    func removeRecordCoreData(_ id: UUID, with date: Date) throws {
        let request = TrackerRecordCoreData.fetchRequest()
        
        do {
            let trackerRecords = try context.fetch(request)
            let calendar = Calendar.current
            let filteredRecord = trackerRecords.first {
                $0.identifier == id && calendar.isDate($0.date!, inSameDayAs: date)
            }
            
            if let trackerRecordCoreData = filteredRecord {
                context.delete(trackerRecordCoreData)
                print("✅ Трекер \(trackerRecordCoreData) удален из записи")
                try saveContext()
            } else {
                print("Запись с id \(id) и датой \(date) не найдена")
            }
        } catch {
            print("Ошибка при удалении трекера из хранилища: \(error)")
            throw error
        }
    }
    
    private func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    private func getTrackerRecords() throws -> [TrackerRecord]? {
        let request = TrackerRecordCoreData.fetchRequest()
        let objects = try context.fetch(request)
        let records = try objects.map { try self.createNewRecord($0) }
        print("✅ Трекеры \(records) находятся в записи")
        return records
    }
    
    private func createNewRecord(_ recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        guard
            let id = recordCoreData.identifier,
            let date = recordCoreData.date else {
            throw NSError(domain: "com.myapp.error", code: 1003, userInfo: [NSLocalizedDescriptionKey: "Ошибка в получение id или data"])
        }
        let trackerRecord = TrackerRecord(id: id, date: date)
        print("✅ Создан \(trackerRecord) для записи с id \(id) и датой \(date)")
        return trackerRecord
    }
    
    func countRecords() -> Int {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        do {
            let count = try context.count(for: request)
            print("В хранилище \(count) записей")
            return count
        } catch {
            print("Ошибка при получении количества записей: \(error)")
            return 0
        }
    }
    
    func deleteAllRecords() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try saveContext()
            print("Все записи удалены")
        } catch {
            print("Ошибка при удалении записей: \(error)")
        }
    }
}
