//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import CoreData
import UIKit

protocol TrackerCategoryDelegate: AnyObject {
    func trackerCategoryDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    static let shared = TrackerCategoryStore()
    
    weak var delegate: TrackerCategoryDelegate?
    
    var categories: [TrackerCategory] {
        let categories = try? getListCategories().map { try self.convertToTrackerCategory($0) }
        return categories ?? []
    }
    
    private let trackerStore = TrackerStore.shared
    
    private let context: NSManagedObjectContext
    
    private var categoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
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
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "header", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        self.categoryFetchedResultsController = controller
        try? controller.performFetch()
    }
    
    func createCategoryCoreData(with header: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.header = header
        category.trackers = []
        try saveContext()
    }
    
    func convertToTrackerCategory(_ model: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let tracker = model.trackers else {
            throw NSError(domain: "com.myapp.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Ошибка в заголовке"])
        }
        
        guard let header = model.header else {
            throw NSError(domain: "com.myapp.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Ошибка в заголовке"])
        }
        
        let category = TrackerCategory(
            header: header,
            trackers: tracker.compactMap { coreDataTracker -> Tracker? in
                if let coreDataTracker = coreDataTracker as? TrackerCoreData {
                    return try? trackerStore.convertTrackerFromCoreData(coreDataTracker)
                } else {
                    return nil
                }
            })
        return category
    }
    
    func fetchTrackerCategoryCoreData(title: String) throws -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        request.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.header), title)
        
        guard let category = try context.fetch(request).first else {
            throw NSError(domain: "com.myapp.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Ошибка в названии"])
        }
        return category
    }
    
    func getListCategories() throws -> [TrackerCategoryCoreData] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.returnsObjectsAsFaults = false
        var list: [TrackerCategoryCoreData]?
        do {
            list = try context.fetch(request)
        } catch {
            throw NSError(domain: "com.myapp.error", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Ошибка в запросе"])
        }
        guard let categories = list else {
            fatalError("Ошибка в запросе")
        }
        return categories
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
    
    // Метод для удаления всех категорий
    func deleteAllCategories() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            for category in categories {
                context.delete(category)
            }
            try saveContext()
            print("Все категории удалены")
        } catch {
            print("Ошибка при удалении категорий: \(error)")
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryDidUpdate()
    }
}
