//
//  ButtonPrimary.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct ButtonPrimary: View {
    let title: String
    let action: () -> Void
    var isLoading: Bool = false
    var disabled: Bool = false

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if !isLoading { action() } 
        }) {
            HStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.9)
                } else {
                    Text(title)
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                (disabled || isLoading)
                ? Color.brandBlue.opacity(0.5)
                : (isPressed ? Color.brandBlue.opacity(0.8) : Color.brandBlue)
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(disabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        ButtonPrimary(title: "Sign Up", action: {})
        ButtonPrimary(title: "Loading...", action: {}, isLoading: true)
        ButtonPrimary(title: "Disabled", action: {}, disabled: true)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
