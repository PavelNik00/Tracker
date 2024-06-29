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
    
    static let shared = TrackerStore()
    
    weak var delegate: TrackerStoreDelegate?
    
    private var trackers: [Tracker] {
        guard
            let objects = self.trackersFetchedResultsController?.fetchedObjects,
            let trackers = try? objects.map({ try convertTrackerFromCoreData($0) }) else {
            return []
        }
        return trackers
    }
    
    private let uiColorMarshalling = UIColorMarshalling()
    
    private let recordStore = TrackerRecordStore.shared
    
    private var context: NSManagedObjectContext
    
    private var trackersFetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        
        self.init(context: context)
    }
    
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
    
    func addCoreDataTracker(_ tracker: Tracker, with category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.identifier = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule
        trackerCoreData.category = category
        try saveContext()
    }
    
    func convertTrackerFromCoreData(_ modelCoreData: TrackerCoreData) throws -> Tracker {
        guard let id = modelCoreData.identifier,
              let name = modelCoreData.name,
              let colorString = modelCoreData.color,
              let emoji = modelCoreData.emoji,
              let schedule = modelCoreData.schedule else {
            throw NSError(domain: "com.myapp.error", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Ошибка преобразования CoreData в Tracker"])
        }
        let color = uiColorMarshalling.color(from: colorString)
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule 
        )
    }
    
    func trackerUpdate(_ record: TrackerRecord) throws {
        let newRecord = recordStore.createCoreDataTrackerRecord(from: record)
        let request = TrackerCoreData.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.identifier),
            record.id as CVarArg)
        
        guard let trackers = try? context.fetch(request) else { return }
        if let trackerCoreData = trackers.first {
            trackerCoreData.addToRecord(newRecord)
            try saveContext()
        }
        print("✅ Трекер \(trackers) сохранен в Core Data")
    }
    
    func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
    // Метод для удаления всех трекеров
    func deleteAllTrackers() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackers = try context.fetch(fetchRequest)
            for tracker in trackers {
                context.delete(tracker)
            }
            try saveContext()
            print("Все трекеры удалены")
        } catch {
            print("Ошибка при удалении трекеров: \(error)")
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerStoreDidUpdate()
    }
}
