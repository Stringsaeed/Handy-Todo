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
    @ObservedObject var viewModel: TodoViewModel
    
    
    init(category: Category, viewModel: TodoViewModel? = nil) {
        self.category = category
        self.viewModel = viewModel ?? TodoViewModel(category: category)
    }
    
    var body: some View {
        ScrollView {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.handWritten(10))
                    .foregroundColor(.red)
            }
            HStack{
                Label(category.rawValue, systemImage: category.getImageName())
                .font(.handWritten(24))
                Spacer()
            }
            TextField("New Todo", text: $newTodoText)
                .font(.handWritten(20))
                .onSubmit {
                    viewModel.addTodo(text: newTodoText)
                    newTodoText = ""
                }
                .padding(.bottom)
                .accessibilityLabel("\(category.rawValue)_testInput")
            ForEach(viewModel.todos, id: \.id) { item in
                TodoView(item: item)
                    .onTapGesture {
                        withAnimation {
                            var updateItem = item
                            updateItem.isFinsihed.toggle()
                            viewModel.updateTodo(todo: updateItem)
                        }
                    }
                    .padding(.bottom, 8)
            }.onDelete(perform: viewModel.deleteTodos)
            
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(.horizontal, 16)
    }
}

struct TodoCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        TodoCategoryView(category: .primary, viewModel: TodoViewModel(category: .primary))
    }
}
