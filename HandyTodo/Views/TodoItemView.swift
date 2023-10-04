//
//  TodoItemView.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()

struct TodoItemView: View {
    @ObservedObject var item: TodoItem
    
    var body: some View {
        Label {
            Text(item.text ?? "")
                .accessibilityLabel(item.text ?? "")
                .accessibilityIdentifier(item.text ?? "")
            Spacer()
            Text("\(item.date ?? .now, formatter: itemFormatter)")
        } icon: {
            Image(systemName: item.isFinished ?  "checkmark.circle.fill": "circle")
                .foregroundColor(.white)
        }
        .font(.handWritten(21))
        .animation(.easeInOut, value: item.isFinished)
        .transition(.slide)
        .strikethrough(item.isFinished)
    }
}

struct TodoItemView_Previews: PreviewProvider {
    static var previews: some View {
        let item: TodoItem = {
            let theItem = TodoItem(context: PersistenceController.preview.container.viewContext)
            theItem.category = "Primary"
            theItem.text = "test test test testtest testtesttesttesttest"
            theItem.id = .init()
            theItem.date = .now
            theItem.timestamp = .now
            theItem.isFinished = false
            return theItem
        }()
        
        return TodoItemView(item: item)
    }
}
