//
//  ContentView.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var body: some View {
        VStack {
            HeaderView()
            
            Grid {
                GridRow {
                    TodoCategoryView(category: .primary)
                }
                Divider()
                    .overlay(.white)
                
                if UIDevice.isIPhone {
                    GridRow {
                        TodoCategoryView(category: .secondary)
                    }
                    .padding(.top, 16)
                    Divider()
                        .overlay(.white)
                    GridRow {
                        TodoCategoryView(category: .tertiary)
                    }
                    .padding(.top, 16)
                } else if UIDevice.isIPad {
                    GridRow {
                        TodoCategoryView(category: .secondary)
                        TodoCategoryView(category: .tertiary)
                    }
                    .padding(.top, 16)
                }
            }
            .padding(.all)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(.black)
            .foregroundColor(.white)
        }
    }
}

struct ContentView_Previews_iPhone: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 14")
    }
}


struct ContentView_Previews_iPad: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad (10th generation)")
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
    }
}
