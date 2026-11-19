import AppKit
import Foundation

func generateIcon() {
    let size = NSSize(width: 1024, height: 1024)
    let image = NSImage(size: size)
    
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else { return }
    
    // Background squircle
    let rect = CGRect(origin: .zero, size: CGSize(width: 1024, height: 1024))
    let path = CGPath(roundedRect: rect.insetBy(dx: 48, dy: 48), cornerWidth: 220, cornerHeight: 220, transform: nil)
    ctx.addPath(path)
    ctx.clip()

    // Background Gradient (Dark Slate to Deep Indigo)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 1.0).cgColor,
        NSColor(red: 0.04, green: 0.05, blue: 0.08, alpha: 1.0).cgColor
    ] as CFArray
    if let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 512, y: 1024), end: CGPoint(x: 512, y: 0), options: [])
    }

    // Outer Glow Ring / Gauge Track
    let center = CGPoint(x: 512, y: 480)
    let radius: CGFloat = 310

    ctx.setLineWidth(32)
    ctx.setLineCap(.round)
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.1).cgColor)
    ctx.addArc(center: center, radius: radius, startAngle: -.pi * 0.75, endAngle: .pi * 0.75, clockwise: false)
    ctx.strokePath()

    // Gauge Active Arc (Cyan to Purple)
    ctx.setLineWidth(34)
    ctx.setLineCap(.round)
    ctx.setStrokeColor(NSColor(red: 0.2, green: 0.8, blue: 0.9, alpha: 0.95).cgColor)
    ctx.addArc(center: center, radius: radius, startAngle: -.pi * 0.75, endAngle: .pi * 0.35, clockwise: false)
    ctx.strokePath()

    // Center Core Knob
    ctx.setFillColor(NSColor(red: 0.12, green: 0.14, blue: 0.22, alpha: 1.0).cgColor)
    ctx.fillEllipse(in: CGRect(x: center.x - 70, y: center.y - 70, width: 140, height: 140))
    ctx.setStrokeColor(NSColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.6).cgColor)
    ctx.setLineWidth(8)
    ctx.strokeEllipse(in: CGRect(x: center.x - 70, y: center.y - 70, width: 140, height: 140))

    // Needle
    ctx.setLineWidth(16)
    ctx.setLineCap(.round)
    ctx.setStrokeColor(NSColor(red: 0.95, green: 0.75, blue: 0.2, alpha: 1.0).cgColor)
    ctx.move(to: center)
    let needleAngle = .pi * 0.30
    let needleEnd = CGPoint(x: center.x + cos(needleAngle) * 230, y: center.y + sin(needleAngle) * 230)
    ctx.addLine(to: needleEnd)
    ctx.strokePath()

    // Top "AI" Text
    let font = NSFont.systemFont(ofSize: 110, weight: .heavy)
    let text = "AI"
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: NSColor(red: 0.35, green: 0.75, blue: 1.0, alpha: 1.0)
    ]
    let attrStr = NSAttributedString(string: text, attributes: attrs)
    let strSize = attrStr.size()
    attrStr.draw(at: CGPoint(x: 512 - strSize.width / 2, y: 760))

    // Subtitle "METER"
    let subFont = NSFont.systemFont(ofSize: 52, weight: .bold)
    let subAttrs: [NSAttributedString.Key: Any] = [
        .font: subFont,
        .foregroundColor: NSColor(white: 0.85, alpha: 0.9)
    ]
    let subStr = NSAttributedString(string: "METER", attributes: subAttrs)
    let subSize = subStr.size()
    subStr.draw(at: CGPoint(x: 512 - subSize.width / 2, y: 700))

    image.unlockFocus()

    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else {
        print("Failed to render PNG")
        return
    }

    let outURL = URL(fileURLWithPath: "Resources/AppIcon_1024.png")
    try? png.write(to: outURL)
    print("Icon generated at Resources/AppIcon_1024.png")
}

generateIcon()
