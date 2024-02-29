//
//  KeypadStyle.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 29/02/24.
//

import SwiftUI

public struct KeypadStyle {
    
    public private(set) var numberButtonStyle: KeypadButtonStyle?
    
//    //Numeric Buttons
//    public private(set) var numericButtonFont: UIFont?
//    public private(set) var numericButtonBackground: Color?
//    public private(set) var numericButtonForeground: Color?
    
    //Delete Button
    public private(set) var deleteButtonImage: Image?

    
    public init(numberButtonStyle: KeypadButtonStyle?,
                deleteButtonImage: Image? = nil) {
        self.numberButtonStyle = numberButtonStyle
        self.deleteButtonImage = deleteButtonImage
    }
    
    public static let MaterialKeypadStyle = KeypadStyle(numberButtonStyle: KeypadStyle.MaterialKeypabButtonStyle)
    
    public static let MaterialKeypabButtonStyle = KeypadButtonStyle(backgroundColor: .blue, foregroundColor: .white, borderColor: .clear, borderWidth: 0, cornerRadius: 4, font: Font(UIFont.systemFont(ofSize: 24.0, weight: .regular)))

    public static let DefaultKeypadStyle = KeypadStyle(numberButtonStyle: KeypadStyle.DefaultKeypabButtonStyle)

    public static let DefaultKeypabButtonStyle = KeypadButtonStyle()
    
}
