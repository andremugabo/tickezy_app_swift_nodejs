//
//  AppIconCanvas.swift
//  TICKEZY
//
//  Created by M.A on 11/15/25.
//

import SwiftUI

struct AppIconCanvas: View {
    // Target aspect: square 1024x1024. Scales well at any size.
    let size: CGFloat

    var body: some View {
        ZStack {
            // Background (no transparency)
            LinearGradient(
                colors: [Color.brandPrimary, Color.brandAccent],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Ticket silhouette
            TicketShape()
                .fill(Color.white.opacity(0.08))
                .padding(size * 0.10)

            // Inner badge with monogram
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.14, style: .continuous)
                    .fill(Color.white.opacity(0.14))

                // Monogram “T” + check
                HStack(spacing: size * 0.06) {
                    Text("T")
                        .font(.system(size: size * 0.36, weight: .heavy))
                        .foregroundColor(.white)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: size * 0.24, weight: .semibold))
                        .foregroundStyle(Color.white, Color.white.opacity(0.85))
                }
            }
            .padding(size * 0.24)
        }
        .frame(width: size, height: size)
        .clipped()
        // Keep square corners; iOS applies rounding automatically.
    }
}

struct TicketShape: Shape {
    func path(in rect: CGRect) -> Path {
        // A simple ticket silhouette with notches on left/right centers
        let notchRadius = min(rect.width, rect.height) * 0.08
        let corner = min(rect.width, rect.height) * 0.18
        var p = Path()
        p.addRoundedRect(in: rect, cornerSize: CGSize(width: corner, height: corner))

        // Carve circles left/right for ticket notches
        let leftCenter = CGPoint(x: rect.minX, y: rect.midY)
        let rightCenter = CGPoint(x: rect.maxX, y: rect.midY)

        p.addPath(Path { k in
            k.addEllipse(in: CGRect(
                x: leftCenter.x - notchRadius,
                y: leftCenter.y - notchRadius,
                width: notchRadius * 2,
                height: notchRadius * 2
            ))
        })
        p.addPath(Path { k in
            k.addEllipse(in: CGRect(
                x: rightCenter.x - notchRadius,
                y: rightCenter.y - notchRadius,
                width: notchRadius * 2,
                height: notchRadius * 2
            ))
        })

        // Use even-odd to carve out notches
        return p.eoFilled()
    }
}

private extension Path {
    func eoFilled() -> Path {
        var p = self
        p = p.strokedPath(.init(lineWidth: 0)) // normalize
        return p
    }
}

#Preview {
    AppIconCanvas(size: 300)
        .previewLayout(.sizeThatFits)
}
