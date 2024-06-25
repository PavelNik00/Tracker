//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

protocol TrackerStoreDelegate: AnyObject {
    
}

final class TrackerStore: NSObject {
    
    // синглтон для доступа
    static let shared = TrackerStore()
    
    // делегат для уведомления об изменении данных
    weak var delegate: TrackerStoreDelegate?
    
    // переменная для списка трекеров получаемых из Core Data
    private var trackers: [Tracker] {
        //
        return trackers
    }
    
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
    
}
