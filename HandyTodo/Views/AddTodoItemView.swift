//
//  AddTodoItemView.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI

struct AddTodoView: View {
    var onDone: (_ text: String, _ date: Date, _ category: Category) -> Void
    @State var category: Category
    @State var text: String = ""
    @State var dueDate: Date = .now
    
    func createTodo() {
        onDone(text, dueDate, category)
    }
    
    var body: some View {
        Form {
            HStack{
                Text("Title")
                    .foregroundColor(.gray)
                Spacer()
                TextField("ex:. work", text: $text)
                    .multilineTextAlignment(.trailing)
            }
            .font(.handWritten(18))
            
            DatePicker("When should it done?", selection: $dueDate, displayedComponents: .hourAndMinute)
                .font(.handWritten(18))
                .foregroundColor(.gray)
            Picker("in which level?", selection: $category) {
                ForEach(Category.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .font(.handWritten(18))
            .foregroundColor(.gray)
            .id(category.rawValue)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    createTodo()
                } label: {
                    Text("Done")
                        .font(.handWritten())
                        .foregroundColor(.white)
                }
            }
        }
        .background(.black)
    }
}

struct AddTodoView_Previews: PreviewProvider {
    static var previews: some View {
        AddTodoView(onDone: { todo,_,_  in
            print(todo)
        }, category: .secondary)
    }
}
