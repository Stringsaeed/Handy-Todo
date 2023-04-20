//
//  FirestoreManager.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation

class TodoViewModel: ObservableObject {
    var category: Category = .primary
    @Published var todos = [Todo]()
    @Published var errorMessage: String?
    
    
    private var db = Firestore.firestore()
    private let auth = Auth.auth()
    
    
    init(category: Category) {
        self.category = category
        self.getTodos()
    }
    
    func getTodos() {
        guard let userId = auth.currentUser?.uid else { return }
        
        let today = Timestamp(date: Date())
        let calendar = Calendar(identifier: .gregorian)
        let todayAtMidnight = calendar.startOfDay(for: today.dateValue())

        db.collection("todos")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThan: todayAtMidnight)
            .whereField("category", isEqualTo: category.rawValue)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    self?.errorMessage = "No documents in 'todos' collection"
                    return
                }
                
                self?.errorMessage = nil
                self?.todos = documents.compactMap { queryDocumentSnapshot in
                    return try? queryDocumentSnapshot.data(as: Todo.self)
                }
            }
    }
    
    func addTodo(text: String) {
        guard let userId = auth.currentUser?.uid else { return }
    
        do {
            let todo = Todo(
                text: text,
                date: .now,
                category: category,
                isFinsihed: false,
                userId: userId
            )
            
            let _ = try db.collection("todos").addDocument(from: todo)
        } catch {
            self.errorMessage = "Can't save todo"
        }
    }
    
    func updateTodo(todo: Todo) {
        guard let id = todo.id else { return }
        do {
            try db.collection("todos").document(id).setData(from: todo)
        } catch {
            self.errorMessage = "Can't update todo"
        }
    }
    
    func deleteTodo(id: String) {
        db.collection("todos").document(id).delete() { err in
            self.errorMessage = err?.localizedDescription
        }
    }
    
    func deleteTodos(at offsets: IndexSet) {
        let itemsToDelete = offsets.lazy.map { self.todos[$0] }
        itemsToDelete.forEach {item in
            if let id = item.id {
                deleteTodo(id: id)
            }
        }
    }
}
