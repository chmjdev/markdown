import AppKit
let directory = "ios/Resources/Assets.xcassets/AppIcon.appiconset"
let context = CGContext(data: nil, width: 1024, height: 1024, bitsPerComponent: 8, bytesPerRow: 4096, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
let graphics = NSGraphicsContext(cgContext: context, flipped: false)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics
NSColor(calibratedRed: 0.18, green: 0.28, blue: 0.23, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 1024)).fill()
NSColor(calibratedWhite: 0.97, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 203, y: 170, width: 618, height: 684), xRadius: 55, yRadius: 55).fill()
let text = "m↓" as NSString
let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 265, weight: .bold), .foregroundColor: NSColor(calibratedRed: 0.18, green: 0.28, blue: 0.23, alpha: 1)]
let bounds = text.size(withAttributes: attributes)
text.draw(at: NSPoint(x: (1024 - bounds.width) / 2, y: 390), withAttributes: attributes)
NSColor(calibratedRed: 0.63, green: 0.7, blue: 0.64, alpha: 1).setFill()
NSBezierPath(roundedRect: NSRect(x: 300, y: 300, width: 424, height: 25), xRadius: 12, yRadius: 12).fill()
NSGraphicsContext.restoreGraphicsState()
let bitmap = NSBitmapImageRep(cgImage: context.makeImage()!)
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(directory)/AppIcon.png"))
let manifest = """
{"images":[{"filename":"AppIcon.png","idiom":"universal","platform":"ios","size":"1024x1024"}],"info":{"author":"xcode","version":1}}
"""
try manifest.write(toFile: "\(directory)/Contents.json", atomically: true, encoding: .utf8)
