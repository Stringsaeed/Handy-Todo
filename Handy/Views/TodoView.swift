//
//  TodoView.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import SwiftUI

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
}()


struct TodoView: View {
    let item: Todo
    
    var body: some View {
        Label {
            Text(item.text)
                .accessibilityLabel(item.text)
                .accessibilityIdentifier(item.text)
                .lineLimit(1)
            Spacer()
            Text("\(item.date!, formatter: itemFormatter)")
        } icon: {
            Image(systemName: item.isFinsihed ?  "checkmark.circle.fill": "circle")
                .foregroundColor(.white)
        }
        .font(.handWritten(21))
        .strikethrough(item.isFinsihed)
    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(item: .init(text: "test test test testtest testtesttesttesttest", date: .now, category: .primary, isFinsihed: false))
    }
}
