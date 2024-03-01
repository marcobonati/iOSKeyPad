//
//  KeypadStyle.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 29/02/24.
//

import SwiftUI

public struct KeypadStyle {
    
    public private(set) var numberButtonStyle: KeypadButtonStyle?
    public private(set) var operatorButtonFont: Font?
    public private(set) var deleteButtonImage: Image?

    
    public init(numberButtonStyle: KeypadButtonStyle?,
                deleteButtonImage: Image? = nil,
                operatorButtonFont: Font? = nil) {
        self.numberButtonStyle = numberButtonStyle
        self.deleteButtonImage = deleteButtonImage
        self.operatorButtonFont = operatorButtonFont
    }
    
    public static let MaterialKeypadStyle = KeypadStyle(numberButtonStyle: KeypadStyle.MaterialKeypabButtonStyle)
    
    public static let MaterialKeypabButtonStyle = KeypadButtonStyle(backgroundColor: .blue, foregroundColor: .white, borderColor: .clear, borderWidth: 0, cornerRadius: 4, font: Font(UIFont.systemFont(ofSize: 24.0, weight: .regular)))

    public static let DefaultKeypadStyle = KeypadStyle(numberButtonStyle: KeypadStyle.DefaultKeypabButtonStyle, operatorButtonFont: Font(UIFont.systemFont(ofSize: 28.0, weight: .regular)))

    public static let DefaultKeypabButtonStyle = KeypadButtonStyle()
    
}
