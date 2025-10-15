//
//  AnimatedToast.swift
//  TICKEZY
//
//  Created by M.A on 10/15/25.
//

import SwiftUI

struct AnimatedToast: View {
    let message: String
    let isSuccess: Bool
    
    @State private var offsetY: CGFloat = -150
    
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
        .background(.ultraThinMaterial) // blurred background
        .background(isSuccess ? Color.green.opacity(0.85) : Color.red.opacity(0.85))
        .cornerRadius(16)
        .shadow(radius: 8)
        .padding(.horizontal, 20)
        .offset(y: offsetY)
        .onAppear {
            withAnimation(.interpolatingSpring(stiffness: 120, damping: 12)) {
                offsetY = 50 // bounce down
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    offsetY = -150 // slide back up
                }
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .zIndex(1)
    }
}

