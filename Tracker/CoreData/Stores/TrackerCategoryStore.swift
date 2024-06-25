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
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
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
        category.tracker = []
        try saveContext()
    }
    
    // Преобразование объекта Core Data в объект TrackerCategory
    func convertToTrackerCategory(_ model: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let tracker = model.tracker else {
            throw fatalError("Ошибка в трекере")
        }
        
        guard let header = model.header else {
            throw fatalError("Ошибка в заголовке")
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
            throw fatalError("Ошибка в запросе по названию")
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
            throw fatalError("Ошибка в запросе")
        }
        guard let categories = list else { fatalError("Ошибка в запросе")}
        return categories
    }
    
    // сохраняем контекст
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

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    // Метод делегата, вызываемый при изменении данных.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryDidUpdate()
    }
}
