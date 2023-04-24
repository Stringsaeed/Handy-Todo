//
//  Category.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import Foundation

enum Category: String, Codable, CaseIterable {
    case primary = "Primary",
         secondary = "Secondary",
         tertiary = "Tertiary"
    
    func getImageName() -> String {
        switch self {
        case .primary:
            return "1.circle"
        case .secondary:
            return "2.circle"
        case .tertiary:
            return "3.circle"
        }
    }
}
