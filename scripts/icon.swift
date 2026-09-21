import AppKit
let folder = CommandLine.arguments[1]
try FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
for size in [16, 32, 128, 256, 512] {
    for scale in [1, 2] {
        let pixels = size * scale
        let image = NSImage(size: NSSize(width: pixels, height: pixels))
        image.lockFocus()
        let context = NSGraphicsContext.current!.cgContext
        context.scaleBy(x: CGFloat(pixels) / 1024, y: CGFloat(pixels) / 1024)
        NSColor(calibratedRed: 0.18, green: 0.28, blue: 0.23, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 48, y: 48, width: 928, height: 928), xRadius: 210, yRadius: 210).fill()
        NSColor(calibratedWhite: 0.97, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 203, y: 170, width: 618, height: 684), xRadius: 55, yRadius: 55).fill()
        let text = "m↓" as NSString
        let attrs: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 265, weight: .bold), .foregroundColor: NSColor(calibratedRed: 0.18, green: 0.28, blue: 0.23, alpha: 1)]
        let bounds = text.size(withAttributes: attrs)
        text.draw(at: NSPoint(x: (1024-bounds.width)/2, y: 390), withAttributes: attrs)
        NSColor(calibratedRed: 0.63, green: 0.7, blue: 0.64, alpha: 1).setFill()
        NSBezierPath(roundedRect: NSRect(x: 300, y: 300, width: 424, height: 25), xRadius: 12, yRadius: 12).fill()
        image.unlockFocus()
        let bitmap = NSBitmapImageRep(data: image.tiffRepresentation!)!
        let suffix = scale == 2 ? "@2x" : ""
        try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(folder)/icon_\(size)x\(size)\(suffix).png"))
    }
}
