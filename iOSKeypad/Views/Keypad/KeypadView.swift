//
//  KeypadView.swift
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI

public struct KeypadView: View, KeypadButtonDelegate {
    
    @Binding var showSecondaryButtons: Bool
    @Binding var values: [KeypadValueElement]
    @Binding var expression: String
    @Binding var totalAmount: Double
    
    @State private var internalBuffer: String = ""
    private let textConverter = KeypadViewTextConverter(decimals: 2)
    private let numberFormatter: NumberFormatter
    private var hapticFeedback: Bool
    private var clickSound: Bool
    let softFeedback = UIImpactFeedbackGenerator(style: .soft)
    let keyboardFeedback = UIImpactFeedbackGenerator(style: .light)

    public init(values: Binding<[KeypadValueElement]>,
         showSecondaryButtons: Binding<Bool>,
         totalAmount: Binding<Double>,
         expression: Binding<String>,
         numberFormatter: NumberFormatter? = nil,
         hapticFeedback: Bool? = nil,
         clickSound: Bool? = nil)
    {
        _values = values
        _showSecondaryButtons = showSecondaryButtons
        _totalAmount = totalAmount
        _expression = expression
        self.hapticFeedback = hapticFeedback ?? true
        self.clickSound = clickSound ?? true
        self.numberFormatter = numberFormatter ?? KeypadView.defaultCurrencyFormatter()
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
//        .overlay(content: {
//            Text("Internal buffer: \(internalBuffer)").font(.footnote).foregroundStyle(.secondary)
//        })
    }
    
    func onButtonLongPress(button: KeypadButtonType) {
        self.doSoftFeedback()
        if button == .Accessory_Delete {
            internalBuffer = ""
            values[values.count-1].value = 0
            valueDidChanged(internalBuffer)
        }
        
        if button == .Numeric_00 {
            withAnimation(.snappy(duration: 0.3)) {
                self.showSecondaryButtons.toggle()
            }
        }
    }

    func onButtonPressed(button: KeypadButtonType) {
        self.doKeyboardFeedback()
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
    
    private func handleOperatorPressed(_ button: KeypadButtonType) {
        guard let operatorType = operatorTypeForButton(button) else {
            return
        }
        values.append(.valueElementWithOperator(0, operatorType: operatorType))
        internalBuffer = ""
    }
    
    private func operatorTypeForButton(_ button: KeypadButtonType)-> KeypadValueOperator? {
        switch button {
        case .Operator_Divide:
            return .Division
        case .Operator_Multiply:
            return .Multiplication
        case .Operator_Plus:
            return .Addition
        case .Operator_Minus:
            return .Subtraction
        default:
            return nil
        }
    }
    
    private func valueDidChanged(_ stringValue: String) {
        if values.isEmpty {
            values.append(.valueElement(0))
        }
        values[values.count-1].value = textConverter.keypadTextToDouble(stringValue) ?? 0
        updateComputedValues()
    }

    private func updateComputedValues(){
        self.totalAmount = computeTotalAmount()
        self.expression = makeExpressionText()
    }
    
    public static func defaultCurrencyFormatter()-> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        currencyFormatter.currencySymbol = ""
        return currencyFormatter
    }
    
    private func makeExpressionText()-> String {
        let nonZeroValues = values.filter({ !$0.value.isZero })
        let strValues = nonZeroValues.map {
            let operatorString = $0.operatorType?.rawValue ?? ""
            let valueString = numberFormatter.string(from: NSNumber(value: $0.value)) ?? ""
            return operatorString + " " + valueString
        }
        return strValues.joined()
    }
    
    private func computeTotalAmount()-> Double {
        return values.reduce(0) { (result, item) in
            if (item.operatorType == nil){
                return result + item.value
            }
            switch item.operatorType {
            case .Addition:
                return result + item.value
            case .Subtraction:
                return result - item.value
            default:
                return result
            }
        }
    }

    private func doSoftFeedback(){
        if hapticFeedback {
            softFeedback.impactOccurred()
        }
    }

    private func doKeyboardFeedback(){
        if clickSound {
            SystemSound.playInputClick()
        }
        if hapticFeedback {
            keyboardFeedback.impactOccurred()
        }
    }
    
}

public enum KeypadValueOperator: String {
    case Addition = "+"
    case Subtraction = "-"
    case Multiplication = "x"
    case Division = "÷"
}

public struct KeypadValueElement: Equatable {
    var value: Double
    var operatorType: KeypadValueOperator?
    
    public static func ==(lhs: KeypadValueElement, rhs: KeypadValueElement) -> Bool {
        return lhs.value == rhs.value &&
            lhs.operatorType == rhs.operatorType
    }
    
    public  static func valueElement(_ value: Double)-> KeypadValueElement {
        KeypadValueElement(value: value)
    }
    
    public static func valueElementWithOperator(_ value: Double, operatorType: KeypadValueOperator)-> KeypadValueElement {
        KeypadValueElement(value: value, operatorType: operatorType)
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
