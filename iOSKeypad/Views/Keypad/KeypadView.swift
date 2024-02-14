//
//  KeypadViews.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI

struct KeypadView: View, KeypadButtonDelegate {
    
    @Binding var textValue: String
    @Binding var value: Double
    @Binding var showSecondaryButtons: Bool

    
    @State var textInternal: String = ""
    var model: KeypadModel = .normalKeypad()
    var secondaryModel: KeypadModel = .mathOperationsKeypad()

    var body: some View {
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
        if (button == .Numeric_0 || button == .Numeric_00) && textValue.isEmpty {
            return
        }
        textInternal.append(button.rawValue)
    }

    private func handleDeletePressed(_ button: KeypadButtonType){
        if !textInternal.isEmpty {
            textInternal.removeLast()
        }
    }

    private func handleOperatorPressed(_ button: KeypadButtonType){
        //TODO!!
    }

}

class KeypadButtonDelegateProxy: KeypadButtonDelegate {
    var delegate: KeypadButtonDelegate?
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            Text("112,53$")
                .font(.system(size: 40, weight: .medium, design: .rounded))
            Spacer()
            KeypadView(textValue: .constant(""), value: .constant(3.13), showSecondaryButtons: .constant(true))
                .frame(maxHeight: 450)
                .padding()
            Spacer()
        }
    }
}
