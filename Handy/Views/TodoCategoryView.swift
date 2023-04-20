//
//  TodoCategoryView.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import SwiftUI

struct TodoCategoryView: View {
    let category: Category
    @State var newTodoText: String = ""
    @State var isAddTodoSheetPresented = false
    @ObservedObject var viewModel: TodoViewModel
    
    
    init(category: Category, viewModel: TodoViewModel? = nil) {
        self.category = category
        self.viewModel = viewModel ?? TodoViewModel(category: category)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.todos) { item in
                    TodoView(item: item)
                        .onTapGesture {
                            viewModel.toggleDone(todo: item)
                        }
                }
                .onDelete { viewModel.deleteTodos(at: $0) }
            }
            .listStyle(.plain)
            .refreshable {
                viewModel.getTodos()
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isAddTodoSheetPresented = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("\(category.rawValue) (\(viewModel.todos.count))")
                        .font(.handWritten(28))
                        .font(.largeTitle)
                }
#endif
            }
            .sheet(isPresented: $isAddTodoSheetPresented, onDismiss: {
                isAddTodoSheetPresented = false
            }) {
                NavigationView {
                    AddTodoView(onDone: { todo in
                        viewModel.addTodo(todo: todo)
                        isAddTodoSheetPresented = false
                    }, category: category)
                }
            }
            
        }
    }
}

struct TodoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCategoryView(category: .primary, viewModel: TodoViewModel(category: .primary))
    }
}
