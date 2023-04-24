//
//  TodoService.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI
import CoreData
import Foundation

class TodoService: NSObject, ObservableObject {
    @Published var items: [TodoItem] = .init()
    private let byCategoryController: NSFetchedResultsController<TodoItem>
    private let context: NSManagedObjectContext
    
    
    init(context: NSManagedObjectContext) {
        self.context = context
        self.byCategoryController = .init(fetchRequest: TodoItem.byCategory, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        self.fetchData()
    }
    
    func fetchData() {
        do {
            try self.byCategoryController.performFetch()
            items = self.byCategoryController.fetchedObjects ?? []
            print("date fetched", items)
        } catch {
            print("failed to fetch items!")
        }
    }
    
    func delete(at offset: IndexSet) {
        withAnimation(.spring()) {
            offset.map { items[$0] }.forEach(context.delete)
            saveContext()
        }
    }
    
    func add(text: String, date: Date, category: Category = .primary) {
        let todo = TodoItem(context: context)
        todo.id = UUID()
        todo.text = text
        todo.date = date
        todo.category = category.rawValue
        todo.isFinished = false
        todo.timestamp = .now
        
        saveContext()
    }
    
    func toggleDone(todo: TodoItem) {
        withAnimation(.spring()) {
            items.first(where: { $0.id == todo.id})?.setValue(!todo.isFinished, forKey: "isFinished")
            saveContext()
        }
    }
    
    func saveContext() {
        do {
            try context.save()
            self.fetchData()
        }
        catch {
            print(error.localizedDescription)
            // handle errro
        }
    }
}


extension TodoService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let todoItems = controller.fetchedObjects as? [TodoItem]
        else { return }
        
        items = todoItems
    }
}
