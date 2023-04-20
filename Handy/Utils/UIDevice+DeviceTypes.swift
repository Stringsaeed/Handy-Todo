//
//  UIDevice+DeviceTypes.swift
//  Handy
//
//  Created by Muhammed Saeed on 19/04/2023.
//

import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}
