//
//  Todo.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import FirebaseFirestoreSwift
import Foundation

struct Todo: Codable, Identifiable {
    @DocumentID var id: String?
    var text: String
    var date: Date? = .now
    var category: Category = .primary
    var isFinsihed: Bool = false
    var userId: String?
}
