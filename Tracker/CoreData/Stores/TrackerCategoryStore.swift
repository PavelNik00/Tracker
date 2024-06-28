//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

protocol TrackerCategoryDelegate: AnyObject {
    func trackerCategoryDidUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    // синглтон для хранилища категорий
    static let shared = TrackerCategoryStore()
    
    // делегат для уведомления об изменении данных
    weak var delegate: TrackerCategoryDelegate?
    
    // список категорий получаемых из Core Data
    var categories: [TrackerCategory] {
        let categories = try? getListCategories().map { try self.convertToTrackerCategory($0) }
        return categories ?? []
    }
    
    private let trackerStore = TrackerStore.shared
    
    // контекст Core Data
    private let context: NSManagedObjectContext

    // контроллер для отслеживания изменений в категориях
    private var categoryFetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // получаем контекст из AppDelegate
    convenience override init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Ошибка с инициализацией AppDelegate")
        }
        let context = appDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    // настраиваем контроллер для отслеживания изменений в категориях
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
    
    // Создание новой категории в Core Data
    func createCategoryCoreData(with header: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.header = header
        category.trackers = []
        try saveContext()
    }
    
    // Преобразование объекта Core Data в объект TrackerCategory
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
    
    // Получение категории по названию
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
    
    // Получение списка всех категорий
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
    
    // сохраняем контекст
    func saveContext() throws {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            context.rollback()
            throw error
        }
    }
    
//    // Метод для удаления всех категорий
//    func deleteAllCategories() {
//        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
//        
//        do {
//            let categories = try context.fetch(fetchRequest)
//            for category in categories {
//                context.delete(category)
//            }
//            try saveContext()
//            print("Все категории удалены")
//        } catch {
//            print("Ошибка при удалении категорий: \(error)")
//        }
//    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    // Метод делегата, вызываемый при изменении данных.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryDidUpdate()
    }
}
