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
        HStack {
            Image(systemName: item.isFinsihed ?  "checkmark.circle.fill": "circle")
            Text(item.text)
                .font(.handWritten(21))
                .accessibilityLabel(item.text)
                .accessibilityIdentifier(item.text)
            Spacer()
            Text("\(item.date!, formatter: itemFormatter)")
                .font(.handWritten(21))
        }
        .strikethrough(item.isFinsihed)

    }
}

struct TodoView_Previews: PreviewProvider {
    static var previews: some View {
        TodoView(item: .init(text: "test", date: .now, category: .primary, isFinsihed: false))
    }
}
