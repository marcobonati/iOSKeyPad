//
//  ContentView.swift
//  iOSKeypadTest
//
//  Created by Marco Bonati on 13/02/24.
//

import SwiftUI


struct ContentView: View {
    
    @State var showMathOperations = false
    @State(initialValue: 0) var amount: Double
    @State(initialValue: "") var amountText: String
 
    var body: some View {
        VStack {
        
            VStack {
                Spacer()
                Text(amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .font(.system(size: 40, weight: .medium, design: .rounded))
                Spacer()
                KeypadView(value: $amount,
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
    }
}

#Preview {
    ContentView()
}
