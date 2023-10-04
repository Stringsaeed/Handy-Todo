//
//  TodoCategoryView.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI

struct TodoCategoryView: View {
    let category: Category
    @State var isAddTodoSheetPresented = false
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: TodoItem.entity(), sortDescriptors: [], predicate: nil) var items: FetchedResults<TodoItem>
    
    init(category: Category) {
        _items = FetchRequest(
            entity: TodoItem.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \TodoItem.timestamp, ascending: true)
            ],
            predicate: NSPredicate(format: "category == %@", category.rawValue)
        )
        self.category = category
    }
    
    var gesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                isAddTodoSheetPresented = true
            }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Button {
                        self.toggleDone(todo: item)
                    } label: {
                        TodoItemView(item: item)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { self.delete(at: $0) }
            }
            .gesture(gesture)
            .background(.black)
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddTodoSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.handWritten())
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    if items.count > 0 {
                        Text("\(category.rawValue) (\(items.count))")
                            .font(.handWritten(28))
                            .font(.largeTitle)
                        
                    } else {
                        Text("\(category.rawValue)")
                            .font(.handWritten(28))
                            .font(.largeTitle)
                    }
                }
            }
            .animation(.default, value: items.count)
            .sheet(isPresented: $isAddTodoSheetPresented, onDismiss: {
                isAddTodoSheetPresented = false
            }) {
                NavigationView {
                    AddTodoView(onDone: { text, date, category in
                        self.add(text: text, date: date, category: category)
                        isAddTodoSheetPresented = false
                    }, category: category)
                }
            }
        }
    }
}

struct TodoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCategoryView(category: .primary)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

extension TodoCategoryView {
    func delete(at offset: IndexSet) {
        withAnimation(.spring()) {
            offset.map { items[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    func add(text: String, date: Date, category: Category = .primary) {
        let todo = TodoItem(context: viewContext)
        todo.id = UUID()
        todo.text = text
        todo.date = date
        todo.category = category.rawValue
        todo.isFinished = false
        todo.timestamp = .now
        
        saveContext()
    }
    
    func toggleDone(todo: TodoItem) {
        let itemToUpdate = todo
        itemToUpdate.isFinished.toggle()
        saveContext()
    }
    
    func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print(error.localizedDescription)
            // handle errro
        }
    }
}
