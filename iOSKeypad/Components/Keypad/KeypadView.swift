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
    private var style: KeypadStyle?
    private var numberButtonStyle: KeypadButtonStyle?
    let softFeedback = UIImpactFeedbackGenerator(style: .soft)
    let keyboardFeedback = UIImpactFeedbackGenerator(style: .light)

    public init(values: Binding<[KeypadValueElement]>,
                showSecondaryButtons: Binding<Bool>,
                totalAmount: Binding<Double>,
                expression: Binding<String>,
                style: KeypadStyle? = nil,
                numberFormatter: NumberFormatter? = nil,
                hapticFeedback: Bool? = nil,
                clickSound: Bool? = nil)
    {
        _values = values
        _showSecondaryButtons = showSecondaryButtons
        _totalAmount = totalAmount
        _expression = expression
        self.style = style
        self.numberButtonStyle = style?.numberButtonStyle
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
                                                   text: "1"),
                                 style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_2,
                                                   delegate: self,
                                                   text: "2"),
                                 style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_3,
                                                   delegate: self,
                                                   text: "3"),
                                 style: numberButtonStyle)
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Addition,
                                                       delegate: self,
                                                       text: "+"),
                                     style: numberButtonStyle,
                                     alternativeFont: style?.operatorButtonFont)
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_4,
                                                   delegate: self,
                                                   text: "4"),
                                 style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_5,
                                                   delegate: self,
                                                   text: "5"),
                                 style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_6,
                                                   delegate: self,
                                                   text: "6"),
                                 style: numberButtonStyle)
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Subtraction,
                                                       delegate: self,
                                                       text: "-"),
                                     style: numberButtonStyle,
                                     alternativeFont: style?.operatorButtonFont)
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_7,
                                                   delegate: self,
                                                   text: "7"), style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_8,
                                                   delegate: self,
                                                   text: "8"), style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_9,
                                                   delegate: self,
                                                   text: "9"),
                                 style: numberButtonStyle)
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Operator_Equals,
                                                       delegate: self,
                                                       text: "="),
                                     style: numberButtonStyle,
                                     alternativeFont: style?.operatorButtonFont)
                    }
                }
                HStack {
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_00,
                                                   delegate: self,
                                                   text: "00"), style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Numeric_0,
                                                   delegate: self,
                                                   text: "0"), style: numberButtonStyle)
                    KeypadButton(KeypadButtonModel(buttonType: .Accessory_Delete,
                                                   delegate: self,
                                                   text: "",
                                                   image: deleteImage()), style: numberButtonStyle)
                    if showSecondaryButtons {
                        KeypadButton(KeypadButtonModel(buttonType: .Accessory_Clear,
                                                       delegate: self,
                                                       text: "C"),
                                     style: numberButtonStyle, 
                                     alternativeFont: style?.operatorButtonFont)
                    }
                }
            }
        }
    }
    
    func deleteImage()-> Image {
        return self.style?.deleteButtonImage ?? Image(systemName: "delete.left.fill")
    }
    
    func onButtonLongPress(button: KeypadButtonType) {
        doSoftFeedback()
        if button == .Accessory_Delete {
            clearLast()
        }
        
        if button == .Numeric_00 {
            withAnimation(.snappy(duration: 0.3)) {
                self.showSecondaryButtons.toggle()
            }
        }
    }

    func onButtonPressed(button: KeypadButtonType) {
        doKeyboardFeedback()
        switch button {
        case .Numeric_00, .Numeric_0, .Numeric_1, .Numeric_2, .Numeric_3, .Numeric_4, .Numeric_5, .Numeric_6, .Numeric_7, .Numeric_8, .Numeric_9:
            handleNumericPressed(button)
        case .Accessory_Clear:
            handleClearPressed(button)
        case .Accessory_Delete:
            handleDeletePressed(button)
        case .Operator_Addition, .Operator_Subtraction:
            handleOperatorPressed(button)
        case .Operator_Equals:
            handleEqualsOperatorPressed(button)
        }
    }

    
    private func handleClearPressed(_ button: KeypadButtonType) {
        clearAll()
    }
    
    private func handleNumericPressed(_ button: KeypadButtonType) {
        if (button == .Numeric_0 || button == .Numeric_00) && internalBuffer.isEmpty {
            return
        }
        internalBuffer.append(button.rawValue)
        valueDidChanged(internalBuffer)
    }

    private func handleDeletePressed(_ button: KeypadButtonType) {
        if internalBuffer.isEmpty && values.count <= 1 {
            return
        }
        if !internalBuffer.isEmpty {
            internalBuffer.removeLast()
        } else {
            values.removeLast()
            internalBuffer = textConverter.keypadBufferTextFromDouble(values[values.count-1].value)
        }
        valueDidChanged(internalBuffer)
    }
    
    private func handleOperatorPressed(_ button: KeypadButtonType) {
        guard let operatorType = operatorTypeForButton(button) else {
            return
        }
        values.append(.valueElementWithOperator(0, operatorType: operatorType))
        internalBuffer = ""
        valueDidChanged(internalBuffer)
    }
    
    private func handleEqualsOperatorPressed(_ button: KeypadButtonType) {
        let tempAmount = computeTotalAmount()
        values = []
        internalBuffer = textConverter.keypadBufferTextFromDouble(tempAmount)
        valueDidChanged(internalBuffer)
    }
    
    private func operatorTypeForButton(_ button: KeypadButtonType) -> KeypadValueOperator? {
        switch button {
        case .Operator_Equals:
            return .Equals
        case .Operator_Addition:
            return .Addition
        case .Operator_Subtraction:
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

    private func updateComputedValues() {
        totalAmount = computeTotalAmount()
        expression = makeExpressionText()
    }
    
    private func clearLast(){
        internalBuffer = ""
        values[values.count-1].value = 0
        valueDidChanged(internalBuffer)

    }
    
    private func clearAll(){
        internalBuffer = ""
        values = []
        valueDidChanged(internalBuffer)
    }
    
    public static func defaultCurrencyFormatter() -> NumberFormatter {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        currencyFormatter.currencySymbol = ""
        return currencyFormatter
    }
    
    private func makeExpressionText() -> String {
        let nonZeroValues = values.filter { !$0.value.isZero }
        let strValues = nonZeroValues.map {
            let operatorString = $0.operatorType?.rawValue ?? ""
            let valueString = numberFormatter.string(from: NSNumber(value: $0.value)) ?? ""
            return operatorString + " " + valueString
        }
        return strValues.joined()
    }
    
    private func computeTotalAmount() -> Double {
        return values.reduce(0) { result, item in
            if item.operatorType == nil {
                return result + item.value
            }
            switch item.operatorType {
            case .Addition:
                return result + item.value
            case .Subtraction:
                return result-item.value
            default:
                return result
            }
        }
    }

    private func doSoftFeedback() {
        if hapticFeedback {
            softFeedback.impactOccurred()
        }
    }

    private func doKeyboardFeedback() {
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
    case Equals = "="
}

public struct KeypadValueElement: Equatable {
    var value: Double
    var operatorType: KeypadValueOperator?
    
    public static func ==(lhs: KeypadValueElement, rhs: KeypadValueElement) -> Bool {
        return lhs.value == rhs.value &&
            lhs.operatorType == rhs.operatorType
    }
    
    public static func valueElement(_ value: Double) -> KeypadValueElement {
        KeypadValueElement(value: value)
    }
    
    public static func valueElementWithOperator(_ value: Double, operatorType: KeypadValueOperator) -> KeypadValueElement {
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
    
//    func keypadBufferTextFromDoubleX(_ value: Double) -> String {
//        let numberFormatter = NumberFormatter()
//        if let formattedString = numberFormatter.string(from: NSNumber(value: value)) {
//            return formattedString
//        } else {
//            return ""
//        }
//    }
    
    func keypadBufferTextFromDouble(_ value: Double) -> String {
        let multiplier = Int(pow(10.0, Double(self.decimals)))
        let valueTemp = Double(multiplier) * value
        return value > 0 ? String(Int(valueTemp)) : ""
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Text("112,53$")
                .font(.system(size: 40, weight: .medium, design: .rounded))
            Spacer()
            KeypadView(
                values: .constant([KeypadValueElement(value: 3.35)]),
                showSecondaryButtons: .constant(true),
                totalAmount: .constant(0),
                expression: .constant(""),
                style: KeypadStyle.DefaultKeypadStyle)
                .frame(maxHeight: 450)
                .padding()
            Spacer()
        }
    }
}
