//
//  ContentView.swift
//  Handy
//
//  Created by Muhammed Saeed on 17/04/2023.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
#if os(iOS)
    @State private var orientation = UIDeviceOrientation.unknown
#endif
    
    var body: some View {
        VStack(spacing: .zero) {
            HeaderView()
                .padding(.horizontal)
                .padding(.vertical, 8)
#if os(iOS)
            if UIDevice.isIPad || orientation.isLandscape {
                Divider()
                    .overlay(.white)
                GridPadView()
            } else if UIDevice.isIPhone {
                GridPhoneView()
            }
#elseif os(macOS)
            Divider()
                .overlay(.white)
            GridPadView()
#endif
        }
        .background(.black)
        .foregroundColor(.white)
#if os(iOS)
        .onRotate { newOrientation in
            orientation = newOrientation
        }
#endif
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
