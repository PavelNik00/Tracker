//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidUpdate()
}

final class TrackerStore: NSObject {
    
    // синглтон для доступа
    static let shared = TrackerStore()
    
    // делегат для уведомления об изменении данных
    weak var delegate: TrackerStoreDelegate?
    
    // переменная для списка трекеров получаемых из Core Data
    private var trackers: [Tracker] {
        guard
            let objects = self.trackersFetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try convertTrackerFromCoreData($0) }) else {
            return []
        }
        return trackers
    }
    
    // преобразование цветов
    private let uiColorMarshalling = UIColorMarshalling()
    
    // ссылка на хранилище записей трекеров
    private let recordStore = TrackerRecordStore.shared
    
    // контекст Core Data
    private var context: NSManagedObjectContext
    
    // контроллер для отслеживания изменений в трекерах
    private var trackersFetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // получаем контекст из AppDelegate
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    // настраиваем контроллер для отслеживания изменений в трекерах
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.trackersFetchedResultsController = controller
        try? controller.performFetch()
    }
    
    // метод добавления нового трекера в Core Data
    func addCoreDataTracker(_ tracker: Tracker, with category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.category = category
        try saveContext()
    }
    
    // преобразование объекта Core Data в объект Tracker
    func convertTrackerFromCoreData(_ modelCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = modelCoreData.id,
              let name = modelCoreData.name,
              let colorString = modelCoreData.color,
              let emoji = modelCoreData.emoji,
              let schedule = modelCoreData.schedule else {
            throw fatalError("Ошибка")
        }
        let color = uiColorMarshalling.color(from: colorString)
            
        return Tracker(
                id: id,
                name: name,
                color: color,
                emoji: emoji,
                schedule: schedule)
    }
    
    // обновление трекера
    func trackerUpdate(_ record: TrackerRecord) throws {
        let newRecord = recordStore.createCoreDataTrackerRecord(from: record)
        let request = TrackerCoreData.fetchRequest()
        
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.id), record.id as CVarArg)
        
        guard let trackers = try? context.fetch(request) else { return }
        if let trackerCoreData = trackers.first {
            trackerCoreData.addToRecord(newRecord)
            try saveContext()
        }
    }
    
    // метод для сохранения контекста
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    // метод делегата, вызываемый при изменении данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
