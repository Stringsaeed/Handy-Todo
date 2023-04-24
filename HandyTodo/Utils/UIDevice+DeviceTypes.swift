//
//  UIDevice+DeviceTypes.swift
//  HandyTodo
//
//  Created by Muhammed Saeed on 24/04/2023.
//

#if canImport(UIKit)
import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
#else

struct UIDevice {
    static var isIPad: Bool {
        true
    }
    
    static var isIPhone: Bool {
        false
    }
}

#endif
