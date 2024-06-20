//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Nikipelov on 20.06.2024.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    private let context: NSManagedObjectContext

    // получаем контекст из AppDelegate
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
}
