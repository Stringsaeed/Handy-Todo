//
//  ContentView.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var orientation = UIDeviceOrientation.unknown
    
    var body: some View {
        VStack(spacing: .zero) {
            HeaderView()
                .padding(.horizontal)
                .padding(.vertical, 8)
            if UIDevice.isIPad || orientation.isLandscape {
                Divider()
                    .overlay(.white)
                GridPadView()
            } else if UIDevice.isIPhone {
                GridPhoneView()
            }
        }
        .background(.black)
        .foregroundColor(.white)
        .onRotate { orientation = $0 }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}


struct HeaderView: View {
    let date: Date = .now
    
    var body: some View {
        HStack{
            Spacer()
            Text(date, style: .date)
                .font(.handWritten(24))
        }
        .background(.black)
    }
}

struct GridPadView: View {
    var body: some View {
        HStack(spacing: 0) {
            TodoCategoryView(category: .primary)
                .gridCellColumns(1)
            Divider()
                .overlay(.white)
            VStack(spacing: .zero) {
                TodoCategoryView(category: .secondary)
                Divider()
                    .overlay(.white)
                TodoCategoryView(category: .tertiary)
            }
        }
    }
}

struct GridPhoneView: View {
    var body: some View {
        Grid(verticalSpacing: .zero) {
            GridRow {
                TodoCategoryView(category: .primary)
            }
            Divider()
                .overlay(.white)
            GridRow {
                TodoCategoryView(category: .secondary)
            }
            Divider()
                .overlay(.white)
            GridRow {
                TodoCategoryView(category: .tertiary)
            }
        }
    }
}
