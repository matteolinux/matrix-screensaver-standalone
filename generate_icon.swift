import AppKit

let outputURL = URL(fileURLWithPath: CommandLine.arguments.dropFirst().first ?? "MatrixAppIcon.png")
let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

func drawRoundedRect(_ rect: NSRect, radius: CGFloat, colors: [NSColor]) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    path.addClip()
    let gradient = NSGradient(colors: colors)!
    gradient.draw(in: rect, angle: -38)
}

func drawGlyph(_ text: String, x: CGFloat, y: CGFloat, size: CGFloat, alpha: CGFloat) {
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: size, weight: .semibold),
        .foregroundColor: NSColor(calibratedRed: 0.36, green: 1.0, blue: 0.44, alpha: alpha),
        .paragraphStyle: paragraph
    ]
    text.draw(in: NSRect(x: x, y: y, width: size * 1.2, height: size * 1.3), withAttributes: attrs)
}

image.lockFocus()
NSGraphicsContext.current?.imageInterpolation = .high

let canvas = NSRect(origin: .zero, size: size)
NSColor.clear.setFill()
canvas.fill()

let shadow = NSShadow()
shadow.shadowOffset = NSSize(width: 0, height: -18)
shadow.shadowBlurRadius = 42
shadow.shadowColor = NSColor.black.withAlphaComponent(0.38)
shadow.set()

let iconRect = NSRect(x: 72, y: 72, width: 880, height: 880)
drawRoundedRect(iconRect, radius: 192, colors: [
    NSColor(calibratedRed: 0.005, green: 0.010, blue: 0.012, alpha: 1),
    NSColor(calibratedRed: 0.015, green: 0.080, blue: 0.055, alpha: 1),
    NSColor(calibratedRed: 0.020, green: 0.150, blue: 0.090, alpha: 1)
])

NSShadow().set()

let innerPath = NSBezierPath(roundedRect: iconRect.insetBy(dx: 20, dy: 20), xRadius: 172, yRadius: 172)
NSColor(calibratedWhite: 1, alpha: 0.06).setStroke()
innerPath.lineWidth = 3
innerPath.stroke()

let glyphs = Array("0123456789アイウエオカキクケコサシスセソタチツテト")
for column in 0..<18 {
    let x = iconRect.minX + 38 + CGFloat(column) * 46
    let speedOffset = CGFloat((column * 37) % 90)
    for row in 0..<17 {
        let y = iconRect.minY + 34 + CGFloat(row) * 48 + speedOffset.truncatingRemainder(dividingBy: 24)
        let glyph = String(glyphs[(column * 7 + row * 3) % glyphs.count])
        let fade = max(0.08, min(0.55, CGFloat(row) / 20.0))
        drawGlyph(glyph, x: x, y: y, size: 25, alpha: fade)
    }
}

let mRect = NSRect(x: 205, y: 255, width: 614, height: 450)
let mParagraph = NSMutableParagraphStyle()
mParagraph.alignment = .center

let glowShadow = NSShadow()
glowShadow.shadowOffset = .zero
glowShadow.shadowBlurRadius = 34
glowShadow.shadowColor = NSColor(calibratedRed: 0.0, green: 1.0, blue: 0.28, alpha: 0.85)
glowShadow.set()

let mAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.monospacedSystemFont(ofSize: 370, weight: .black),
    .foregroundColor: NSColor(calibratedRed: 0.74, green: 1.0, blue: 0.76, alpha: 1),
    .paragraphStyle: mParagraph
]
"M".draw(in: mRect, withAttributes: mAttrs)

NSShadow().set()

let highlight = NSBezierPath(roundedRect: NSRect(x: 120, y: 720, width: 784, height: 160), xRadius: 100, yRadius: 100)
highlight.addClip()
let highlightGradient = NSGradient(colors: [
    NSColor.white.withAlphaComponent(0.20),
    NSColor.white.withAlphaComponent(0.02),
    NSColor.white.withAlphaComponent(0.0)
])!
highlightGradient.draw(in: NSRect(x: 120, y: 700, width: 784, height: 210), angle: 90)

image.unlockFocus()

guard
    let tiff = image.tiffRepresentation,
    let bitmap = NSBitmapImageRep(data: tiff),
    let png = bitmap.representation(using: .png, properties: [:])
else {
    fatalError("Cannot render icon PNG")
}

try png.write(to: outputURL)
