//
//  PrimaryCategoryView.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 25/04/2023.
//

import SwiftUI

struct PrimaryCategoryView: View {
    let category = Category.primary
    
    
    var body: some View {
        TodoCategoryView(category: category)
    }
}

struct PrimaryCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryCategoryView()
    }
}
