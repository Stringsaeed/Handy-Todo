//
//  UIDevice+DeviceTypes.swift
//  Handy
//
//  Created by Muhammed Saeed on 19/04/2023.
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
