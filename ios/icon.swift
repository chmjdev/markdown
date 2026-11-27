import AppKit
let directory = "ios/Resources/Assets.xcassets/AppIcon.appiconset"
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 4096, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
let graphics = NSGraphicsContext(cgContext: context, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bgColors = [
    NSColor(calibratedRed: 0.043, green: 0.180, blue: 0.133, alpha: 1).cgColor,
    NSColor(calibratedRed: 0.016, green: 0.106, blue: 0.078, alpha: 1).cgColor
] as CFArray
if let gradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0]) {
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 1024), end: CGPoint(x: 1024, y: 0), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
}
NSColor(calibratedRed: 0.980, green: 0.976, blue: 0.961, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 204, y: 158, width: 616, height: 708), xRadius: 56, yRadius: 56).fill()
let text = "M↓" as NSString
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 220, weight: .heavy),
    .foregroundColor: NSColor(calibratedRed: 0.024, green: 0.306, blue: 0.231, alpha: 1)
]
let bounds = text.size(withAttributes: attributes)
text.draw(at: NSPoint(x: (1024 - bounds.width) / 2, y: 315), withAttributes: attributes)
NSColor(calibratedRed: 0.063, green: 0.725, blue: 0.506, alpha: 0.9).setFill()
NSBezierPath(roundedRect: NSRect(x: 286, y: 690, width: 224, height: 34), xRadius: 17, yRadius: 17).fill()
NSColor(calibratedRed: 0.024, green: 0.306, blue: 0.231, alpha: 0.35).setFill()
NSBezierPath(roundedRect: NSRect(x: 286, y: 626, width: 416, height: 26), xRadius: 13, yRadius: 13).fill()
NSBezierPath(roundedRect: NSRect(x: 286, y: 576, width: 340, height: 24), xRadius: 12, yRadius: 12).fill()
NSGraphicsContext.restoreGraphicsState()
let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(directory)/AppIcon.png"))
let manifest = """
{"images":[{"filename":"AppIcon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}
"""
try manifest.write(toFile: "\(directory)/Contents.json", atomically: true, encoding: .utf8)
