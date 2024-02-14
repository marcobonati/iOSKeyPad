//
//  KeypadViews.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI

struct KeypadView: View, KeypadButtonDelegate {
    
    @Binding var value: Double
    @Binding var showSecondaryButtons: Bool

    @State private var internalBuffer: String = ""
    private var model: KeypadModel = .normalKeypad()
    private var secondaryModel: KeypadModel = .mathOperationsKeypad()
    private let textConverter = KeypadViewTextConverter(decimals: 2)
    
    init(value: Binding<Double>,
         showSecondaryButtons: Binding<Bool>) {
           _value = value
           _showSecondaryButtons = showSecondaryButtons
    }
    
    public var body: some View {
        HStack {
            VStack {
                HStack {
                    KeypadButton(model: model.buttons[0])
                    KeypadButton(model: model.buttons[1])
                    KeypadButton(model: model.buttons[2])
                    if showSecondaryButtons {
                        KeypadButton(model: secondaryModel.buttons[0])
                    }
                }
                HStack {
                    KeypadButton(model: model.buttons[3])
                    KeypadButton(model: model.buttons[4])
                    KeypadButton(model: model.buttons[5])
                    if showSecondaryButtons {
                        KeypadButton(model: secondaryModel.buttons[1])
                    }
                }
                HStack {
                    KeypadButton(model: model.buttons[6])
                    KeypadButton(model: model.buttons[7])
                    KeypadButton(model: model.buttons[8])
                    if showSecondaryButtons {
                        KeypadButton(model: secondaryModel.buttons[2])
                    }
                }
                HStack {
                    KeypadButton(model: model.buttons[9])
                    KeypadButton(model: model.buttons[10])
                    KeypadButton(model: model.buttons[11])
                    if showSecondaryButtons {
                        KeypadButton(model: secondaryModel.buttons[3])
                    }
                }
                
            }
        }.onAppear {
            model.delegate = self
            secondaryModel.delegate = self
        }
    }
    
    func onButtonLongPress(button: KeypadButtonType) {
        if button == .Accessory_Delete {
            self.internalBuffer = ""
            self.value = 0
        }
        
        if button == .Numeric_00 {
            withAnimation(.snappy(duration:0.3)){
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
    
    private func handleNumericPressed(_ button: KeypadButtonType){
        if (button == .Numeric_0 || button == .Numeric_00) && internalBuffer.isEmpty {
            return
        }
        internalBuffer.append(button.rawValue)
        valueDidChanged(internalBuffer)
    }

    private func handleDeletePressed(_ button: KeypadButtonType){
        if !internalBuffer.isEmpty {
            internalBuffer.removeLast()
        }
        valueDidChanged(internalBuffer)
    }

    private func handleOperatorPressed(_ button: KeypadButtonType){
        //TODO!!
    }
    
    private func valueDidChanged(_ stringValue: String){
        self.value = textConverter.keypadTextToDouble(stringValue) ?? 0
    }

}

class KeypadButtonDelegateProxy: KeypadButtonDelegate {
    var delegate: KeypadButtonDelegate?
    func onButtonLongPress(button: KeypadButtonType) {
        delegate?.onButtonLongPress(button: button)
    }
    func onButtonPressed(button: KeypadButtonType) {
        delegate?.onButtonPressed(button: button)
    }
}

class KeypadModel: ObservableObject, KeypadButtonDelegate {
    var buttons: [KeypadButtonModel]
    var buttonsDelegateProxy: KeypadButtonDelegateProxy
    var delegate: KeypadButtonDelegate?
    var textValue: String
    
    let currencyMask = Veil(pattern: "## / ##")
    
    init(buttons: [KeypadButtonModel], buttonsDelegate: KeypadButtonDelegateProxy) {
        self.textValue = ""
        self.buttons = buttons
        self.buttonsDelegateProxy = buttonsDelegate
        self.buttonsDelegateProxy.delegate = self
    }

    func onButtonPressed(button: KeypadButtonType) {
        _onButtonPressed(button: button)
        delegate?.onButtonPressed(button: button)
    }
    
    func onButtonLongPress(button: KeypadButtonType) {
        delegate?.onButtonLongPress(button: button)
    }
    
    func _onButtonPressed(button: KeypadButtonType) {
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
    
    private func handleNumericPressed(_ button: KeypadButtonType){
        if (button == .Numeric_0 || button == .Numeric_00) && textValue.isEmpty {
            return
        }
        textValue.append(button.rawValue)
    }

    private func handleDeletePressed(_ button: KeypadButtonType){
        if !textValue.isEmpty {
            textValue.removeLast()
        }
    }

    private func handleOperatorPressed(_ button: KeypadButtonType){
        //TODO!!
    }

}

extension KeypadModel {
    static func mathOperationsKeypad() -> KeypadModel {
        let delegateProxy = KeypadButtonDelegateProxy()
        var buttons: [KeypadButtonModel] = []
        buttons.append(KeypadButtonModel(buttonType: .Operator_Divide,
                                         delegate: delegateProxy,
                                         text: "",
                                         image: Image(systemName: "divide")))
        buttons.append(KeypadButtonModel(buttonType: .Operator_Multiply,
                                         delegate: delegateProxy,
                                         text: "",
                                         image: Image(systemName: "multiply")))
        buttons.append(KeypadButtonModel(buttonType: .Operator_Minus,
                                         delegate: delegateProxy, 
                                         text: "",
                                         image: Image(systemName: "minus")))
        buttons.append(KeypadButtonModel(buttonType: .Operator_Plus,
                                         delegate: delegateProxy, 
                                         text: "",
                                         image: Image(systemName: "plus")))
        return KeypadModel(buttons: buttons, buttonsDelegate: delegateProxy)
    }

    static func normalKeypad() -> KeypadModel {
        let delegateProxy = KeypadButtonDelegateProxy()
        var buttons: [KeypadButtonModel] = []
        buttons.append(KeypadButtonModel(buttonType: .Numeric_1,
                                         delegate: delegateProxy,
                                         text: "1"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_2,
                                         delegate: delegateProxy,
                                         text: "2"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_3,
                                         delegate: delegateProxy,
                                         text: "3"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_4,
                                         delegate: delegateProxy,
                                         text: "4"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_5,
                                         delegate: delegateProxy,
                                         text: "5"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_6,
                                         delegate: delegateProxy,
                                         text: "6"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_7,
                                         delegate: delegateProxy,
                                         text: "7"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_8,
                                         delegate: delegateProxy,
                                         text: "8"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_9,
                                         delegate: delegateProxy,
                                         text: "9"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_00,
                                         delegate: delegateProxy,
                                         text: "00"))
        buttons.append(KeypadButtonModel(buttonType: .Numeric_0,
                                         delegate: delegateProxy,
                                         text: "0"))
        buttons.append(KeypadButtonModel(buttonType: .Accessory_Delete,
                                         delegate: delegateProxy,
                                         text: "", 
                                         image: Image(systemName: "delete.left.fill")))
        return KeypadModel(buttons: buttons, buttonsDelegate: delegateProxy)
    }
}

fileprivate struct KeypadViewTextConverter {
    
    var decimals: Int
    let numberFormatter = NumberFormatter()
    let locale = Locale.current
    var decimalSeparator: String
    
    init(decimals: Int){
        self.decimals = decimals
        self.numberFormatter.numberStyle = .decimal
        self.numberFormatter.locale = locale
        self.decimalSeparator = locale.decimalSeparator ?? "."
    }
    
    func keypadTextToDouble(_ input: String)-> Double?  {
        let stringNumber = makeStringWithDecimal(padStringWithZeros(input))
        if let formattedNumber = numberFormatter.number(from: stringNumber) {
            return formattedNumber.doubleValue
        } else {
            return nil
        }
    }
    
    func makeStringWithDecimal(_ input: String)-> String {
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Text("112,53$")
                .font(.system(size: 40, weight: .medium, design: .rounded))
            Spacer()
            KeypadView(value: .constant(3.13),
                       showSecondaryButtons: .constant(true))
                .frame(maxHeight: 450)
                .padding()
            Spacer()
        }
    }
}
