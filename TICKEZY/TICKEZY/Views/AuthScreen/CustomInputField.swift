//
//  CustomInputField.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct CustomInputField: View {
    var icon: String
    var placeholder: String
    
    @Binding var text:String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            
           
            
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 20)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.leading, 12)
                    .font(.system(size: 16))
            }
            
            if isSecure {
                SecureField("", text: $text)
                    .foregroundColor(.white)
                    .autocapitalization(.none)
            } else {
                TextField("", text: $text)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.brandBlue, lineWidth: 1)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.1)))
        )
        .cornerRadius(10)
        .foregroundColor(.white)
    }
}




