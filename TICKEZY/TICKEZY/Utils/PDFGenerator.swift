//
//  PDFGenerator.swift
//  TICKEZY
//
//  Created by Antigravity on 12/30/25.
//

import SwiftUI
import UniformTypeIdentifiers

@MainActor
struct PDFGenerator {
    /// Renders a SwiftUI view as a PDF and returns the local file URL
    static func generatePDF<Content: View>(from view: Content, fileName: String) -> URL? {
        let renderer = ImageRenderer(content: view)
        
        // Define standard A4 size in points (72 points per inch)
        let pageWidth: CGFloat = 595.28 // 8.27 inches
        let pageHeight: CGFloat = 841.89 // 11.69 inches
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(fileName).pdf")
        
        renderer.render { size, context in
            var box = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
            
            guard let pdfContext = CGContext(url as CFURL, mediaBox: &box, nil) else {
                return
            }
            
            pdfContext.beginPDFPage(nil)
            
            // Center the view on the page if it's smaller than A4
            let xOffset = (pageWidth - size.width) / 2
            let yOffset = (pageHeight - size.height) / 2
            
            pdfContext.translateBy(x: xOffset, y: yOffset)
            
            context(pdfContext)
            
            pdfContext.endPDFPage()
            pdfContext.closePDF()
        }
        
        return url
    }
}
