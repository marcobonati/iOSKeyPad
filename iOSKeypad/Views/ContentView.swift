//
//  ContentView.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI


struct ContentView: View {
    
    @State var showMathOperations = false
    @State(initialValue: [KeypadValueElement.valueElement(0)]) var values: [KeypadValueElement]
    @State(initialValue: 0) var amount: Double
    @State(initialValue: "") var expression: String
    @State var showExpression = false
    
    let currencyFormatter = NumberFormatter()
    
    init(){
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        currencyFormatter.currencySymbol = ""
    }
    
    var body: some View {
        VStack {
        
            VStack {
                Spacer()
                if (showExpression){
                    Text(expression)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .padding(3)
                }
                
                Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                
                Spacer()
                KeypadView(values: $values,
                           showSecondaryButtons: $showMathOperations,
                           totalAmount: $amount,
                           expression: $expression)
                    .frame(maxHeight: 380)
                    .padding()
                Spacer()
                
                Text("Amount Double Value: \(String(amount))")
                    .font(.footnote)
                
              }

        }
        .padding()
        .onChange(of: values) { _ in
            if (values.count > 1){
                withAnimation(.spring){
                    showExpression = true
                }
            }
        }
    }
    
   
}

#Preview {
    ContentView()
}
