//
//  TodoItem+ByCategory.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import CoreData
import Foundation

extension TodoItem {
    static var byCategory: NSFetchRequest<TodoItem> {
        let request: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        return request
    }
}
