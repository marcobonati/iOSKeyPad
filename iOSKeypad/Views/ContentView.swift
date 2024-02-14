//
//  ContentView.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI


struct ContentView: View {
    
    @State var showMathOperations = false
    @State(initialValue: [0]) var values: [Double]
    @State(initialValue: "") var amountText: String
    @State(initialValue: 0) var amount: Double
    
    @State var showExpression = false
 
    var body: some View {
        VStack {
        
            VStack {
                Spacer()
                if (showExpression){
                    Text(expressionText())
                        .font(.headline)
                        .padding()
                }
                
                Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                
                Spacer()
                KeypadView(values: $values,
                           showSecondaryButtons: $showMathOperations)
                    .frame(maxHeight: 380)
                    .padding()
                Spacer()
                
                Text("Amount Value: \(String(amount))")
                
                Toggle(isOn: $showMathOperations.animation()) {
                    Text("Show Math Operations")
                }
                
               }

        }
        .padding()
        .onChange(of: values) { _ in
            if (values.count > 1){
                withAnimation(.spring){
                    showExpression = true
                }
            }
            self.amount = totalAmount()
        }
    }
    
    func expressionText()-> String {
        var nonZeroValues = values.filter({ !$0.isZero })
        let strValues = nonZeroValues.map { String($0) }
        return strValues.joined(separator: " + ")
    }
    
    func totalAmount()-> Double {
        return values.reduce(0.0, +)
    }
    
}

#Preview {
    ContentView()
}
