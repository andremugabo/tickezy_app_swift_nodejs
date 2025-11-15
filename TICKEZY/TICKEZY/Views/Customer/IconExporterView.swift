//
//  IconExporterView.swift
//  TICKEZY
//
//  Created by M.A on 11/15/25.
//

import SwiftUI

struct IconExporterView: View {
    @State private var status: String = "Ready"

    var body: some View {
        VStack(spacing: 16) {
            AppIconCanvas(size: 256)
                .cornerRadius(48)
                .shadow(radius: 8)

            Button("Export 1024×1024 App Icon PNG") {
                exportIcon()
            }
            .buttonStyle(.borderedProminent)

            Text(status)
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }

    private func exportIcon() {
        let size: CGFloat = 1024
        let iconView = AppIconCanvas(size: size)
        let renderer = ImageRenderer(content: iconView)
        renderer.scale = 1

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("AppIcon_1024.png")

        if let uiImage = renderer.uiImage, let data = uiImage.pngData() {
            do {
                try data.write(to: url)
                status = "Exported to: \(url.path)"
                print("App icon exported to:", url.path)
            } catch {
                status = "Failed to write: \(error.localizedDescription)"
            }
        } else {
            status = "Failed to render image."
        }
    }
}

#Preview {
    IconExporterView()
}

