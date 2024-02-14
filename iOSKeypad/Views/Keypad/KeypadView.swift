//
//  KeypadViews.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI

struct KeypadView: View, KeypadButtonDelegate {
    @Binding var showSecondaryButtons: Bool
    @Binding var values: [KeypadValueElement]

    @State private var internalBuffer: String = ""
    private let textConverter = KeypadViewTextConverter(decimals: 2)
    
    init(values: Binding<[KeypadValueElement]>,
         showSecondaryButtons: Binding<Bool>)
    {
        _values = values
        _showSecondaryButtons = showSecondaryButtons
    }
    
    public var body: some View {
        HStack {
            VStack {
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_1,
                                                   delegate: self,
                                                   text: "1"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_2,
                                                   delegate: self,
                                                   text: "2"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_3,
                                                   delegate: self,
                                                   text: "3"))
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Divide,
                                                       delegate: self,
                                                       text: "",
                                                       image: Image(systemName: "divide"))
                        )
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_4,
                                                   delegate: self,
                                                   text: "4"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_5,
                                                   delegate: self,
                                                   text: "5"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_6,
                                                   delegate: self,
                                                   text: "6"))
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Multiply,
                                                       delegate: self,
                                                       text: "",
                                                       image: Image(systemName: "multiply"))
                        )
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_7,
                                                   delegate: self,
                                                   text: "7"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_8,
                                                   delegate: self,
                                                   text: "8"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_9,
                                                   delegate: self,
                                                   text: "9"))
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Minus,
                                                       delegate: self,
                                                       text: "",
                                                       image: Image(systemName: "minus"))
                        )
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_00,
                                                   delegate: self,
                                                   text: "00"))
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_0,
                                                   delegate: self,
                                                   text: "0"))
                    KeypadButton(KeypadButtonModel(buttonType: .Accessory_Delete,
                                                   delegate: self,
                                                   text: "",
                                                   image: Image(systemName: "delete.left.fill")))
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Plus,
                                                       delegate: self,
                                                       text: "",
                                                       image: Image(systemName: "plus"))
                        )
                    }
                }
            }
        }
        .overlay(content: {
            Text("Internal buffer: \(internalBuffer)").font(.footnote).foregroundStyle(.secondary)
        })
    }
    
    func onButtonLongPress(button: KeypadButtonType) {
        if button == .Accessory_Delete {
            internalBuffer = ""
            values[values.count-1].value = 0
        }
        
        if button == .Numeric_00 {
            withAnimation(.snappy(duration: 0.3)) {
                self.showSecondaryButtons.toggle()
            }
        }
    }

    func onButtonPressed(button: KeypadButtonType) {
        debugPrint("onButtonPressed \(button)")
        switch button {
        case .Numeric_00, .Numeric_0, .Numeric_1, .Numeric_2, .Numeric_3, .Numeric_4, .Numeric_5, .Numeric_6, .Numeric_7, .Numeric_8, .Numeric_9:
            handleNumericPressed(button)
        case .Accessory_Delete:
            handleDeletePressed(button)
        case .Operator_Plus, .Operator_Minus, .Operator_Divide, .Operator_Multiply:
            handleOperatorPressed(button)
        }
    }
    
    private func handleNumericPressed(_ button: KeypadButtonType) {
        if (button == .Numeric_0 || button == .Numeric_00) && internalBuffer.isEmpty {
            return
        }
        internalBuffer.append(button.rawValue)
        valueDidChanged(internalBuffer)
    }

    private func handleDeletePressed(_ button: KeypadButtonType) {
        if (internalBuffer.isEmpty && self.values.count <= 1){
            return
        }
        if !internalBuffer.isEmpty {
            internalBuffer.removeLast()
        } else {
            self.values.removeLast()
            self.internalBuffer = textConverter.keypadBufferTextFromDouble(self.values[self.values.count-1].value)
        }
        valueDidChanged(internalBuffer)
    }
    
    private func internalBufferFromValue(_ value: Double){
        let strValue = String(value)
        
    }
    
    private func handleOperatorPressed(_ button: KeypadButtonType) {
        commitCurrentValue()
    }
    
    private func valueDidChanged(_ stringValue: String) {
        if values.isEmpty {
            values.append(.valueElement(0))
        }
        values[values.count-1].value = textConverter.keypadTextToDouble(stringValue) ?? 0
    }

    private func commitCurrentValue() {
        values.append(.valueElement(0))
        internalBuffer = ""
    }
}

enum KeypadValueOperator {
    case Addition
    case Subtraction
    case Multiplication
    case Division
}

struct KeypadValueElement: Equatable {
    var value: Double
    var operatorType: KeypadValueOperator?
    
    static func ==(lhs: KeypadValueElement, rhs: KeypadValueElement) -> Bool {
        return lhs.value == rhs.value &&
            lhs.operatorType == rhs.operatorType
    }
    
    static func valueElement(_ value: Double)-> KeypadValueElement {
        KeypadValueElement(value: value)
    }
}

private struct KeypadViewTextConverter {
    var decimals: Int
    let numberFormatter = NumberFormatter()
    let locale = Locale.current
    var decimalSeparator: String
    
    init(decimals: Int) {
        self.decimals = decimals
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = locale
        self.decimalSeparator = locale.decimalSeparator ?? "."
    }
    
    func keypadTextToDouble(_ input: String) -> Double? {
        let stringNumber = makeStringWithDecimal(padStringWithZeros(input))
        if let formattedNumber = numberFormatter.number(from: stringNumber) {
            return formattedNumber.doubleValue
        } else {
            return nil
        }
    }
    
    func makeStringWithDecimal(_ input: String) -> String {
        guard input.count >= decimals else {
            return input
        }
        let index = input.index(input.endIndex, offsetBy: -2)
        let modifiedString = input.prefix(upTo: index) + String(decimalSeparator) + input.suffix(from: index)
        return String(modifiedString)
    }
    
    func padStringWithZeros(_ input: String) -> String {
        let padLen = decimals + 1
        if input.count < padLen {
            return String(String(input.reversed()).padding(toLength: padLen, withPad: "0", startingAt: 0).reversed())
        } else {
            return input
        }
    }
    
    func keypadBufferTextFromDouble(_ value: Double)-> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .none
        if let formattedString = numberFormatter.string(from: NSNumber(value: value)) {
            return formattedString
        } else {
            return ""
        }
    }
    
}

// struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            Spacer()
//            Text("112,53$")
//                .font(.system(size: 40, weight: .medium, design: .rounded))
//            Spacer()
//            KeypadView(value: [3.13],
//                       showSecondaryButtons: .constant(true))
//                .frame(maxHeight: 450)
//                .padding()
//            Spacer()
//        }
//    }
// }
