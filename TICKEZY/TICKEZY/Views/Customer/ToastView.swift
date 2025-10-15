//
//  ToastView.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct ToastView: View {
    let message: String
    let isSuccess: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.octagon.fill")
                .foregroundColor(.white)
                .font(.title2)
            
            Text(message)
                .foregroundColor(.white)
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(isSuccess ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
        .cornerRadius(14)
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}


