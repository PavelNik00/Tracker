//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

protocol TrackerCategoryDelegate: AnyObject {
}

final class TrackerCategoryStore: NSObject {
    
    // синглтон для хранилища категорий
    static let shared = TrackerCategoryStore()
    
    // делегат для уведомления об изменении данных
    weak var delegate: TrackerCategoryDelegate?
    
    // список категорий получаемых из Core Data
    var categories: [TrackerCategory] {
        return categories
    }
    
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
    
}
