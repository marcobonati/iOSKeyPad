//
//  KeypadButton.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI

protocol KeypadButtonDelegate {
    func onButtonPressed(button: KeypadButtonType)
    func onButtonLongPress(button: KeypadButtonType)
}

public enum KeypadButtonType: String {
    case Numeric_00 = "00"
    case Numeric_0 = "0"
    case Numeric_1 = "1"
    case Numeric_2 = "2"
    case Numeric_3 = "3"
    case Numeric_4 = "4"
    case Numeric_5 = "5"
    case Numeric_6 = "6"
    case Numeric_7 = "7"
    case Numeric_8 = "8"
    case Numeric_9 = "9"
    case Operator_Plus = "+"
    case Operator_Minus = "-"
    case Operator_Divide = "/"
    case Operator_Multiply = "*"
    case Accessory_Delete = "DEL"
}

struct KeypadButtonModel: Hashable {
        
    var buttonType: KeypadButtonType
    var delegate: KeypadButtonDelegate? = nil
    var text: String
    var image: Image?
    static func == (lhs: KeypadButtonModel, rhs: KeypadButtonModel) -> Bool {
        lhs.text == rhs.text
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(text)
    }
}

struct KeypadButtonStyle {
    var backgroundColor: Color = Color(UIColor(red: 248/255, green: 248/255, blue: 249/255, alpha: 1))
    var foregroundColor: Color = .black
    var borderColor: Color = .clear //Color(UIColor(red: 211/255, green: 213/255, blue: 215/255, alpha: 1))
    var borderWidth: CGFloat = 1
    var cornerRadius: CGFloat = 20
    var font: Font = .system(size: 20, weight: .regular, design: .default)
}

struct KeypadButton: View {
    
    var model: KeypadButtonModel
    var style: KeypadButtonStyle
    
    init(_ model: KeypadButtonModel, style: KeypadButtonStyle? = nil){
        self.model = model
        self.style = style ?? KeypadButtonStyle()
    }
    
    var body: some View {
        VStack {
            
            Button(action: {
                model.delegate?.onButtonPressed(button: model.buttonType)
                  }) {
                        RoundedRectangle(cornerRadius: style.cornerRadius)
                          .fill(style.backgroundColor)
                          .overlay(
                                RoundedRectangle(cornerRadius: style.cornerRadius)
                                    .stroke(style.borderColor, lineWidth: style.borderWidth)
                                    .overlay(
                                        HStack {
                                            model.image
                                            Text(model.text)
                                                .font(style.font)
                                                .foregroundColor(style.foregroundColor)
                                        }
                                    )
                          )
                          .onTapGesture {
                              model.delegate?.onButtonPressed(button: model.buttonType)
                          }
                          .onLongPressGesture(minimumDuration: 0.1) {
                              model.delegate?.onButtonLongPress(button: model.buttonType)
                          }
                  }
                
        }
    }
    
}

#Preview {
    KeypadButton(KeypadButtonModel(buttonType: .Numeric_1,  text: "1")).padding(10)
}


