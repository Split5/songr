#!/usr/bin/env swift

import AppKit
import Foundation

/// Renders the hand-authored SVG master into every Apple asset-catalog size.
/// Run from the project root: `swift tool/render_app_icon.swift`

let fileManager = FileManager.default
let root = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let source = root.appendingPathComponent("assets/branding/musik-app-icon.svg")
let splashSource = root.appendingPathComponent("assets/branding/splash-mark.svg")

guard let vector = NSImage(contentsOf: source),
      let splashVector = NSImage(contentsOf: splashSource) else {
  fputs("Could not load branding SVG masters\n", stderr)
  exit(1)
}

func render(
  image: NSImage,
  size: Int,
  to relativePath: String,
  opaque: Bool = true
) throws {
  guard let bitmapContext = CGContext(
    data: nil,
    width: size,
    height: size,
    bitsPerComponent: 8,
    bytesPerRow: size * 4,
    space: CGColorSpaceCreateDeviceRGB(),
    bitmapInfo: opaque
      ? CGImageAlphaInfo.noneSkipLast.rawValue
      : CGImageAlphaInfo.premultipliedLast.rawValue
  ) else {
    throw NSError(domain: "MusikIcon", code: 1)
  }

  NSGraphicsContext.saveGraphicsState()
  let context = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
  NSGraphicsContext.current = context
  context.imageInterpolation = .high
  image.draw(
    in: NSRect(x: 0, y: 0, width: size, height: size),
    from: .zero,
    operation: .copy,
    fraction: 1
  )
  bitmapContext.flush()
  NSGraphicsContext.restoreGraphicsState()

  guard let image = bitmapContext.makeImage() else {
    throw NSError(domain: "MusikIcon", code: 2)
  }
  let bitmap = NSBitmapImageRep(cgImage: image)
  guard let png = bitmap.representation(using: .png, properties: [:]) else {
    throw NSError(domain: "MusikIcon", code: 3)
  }
  let destination = root.appendingPathComponent(relativePath)
  try png.write(to: destination, options: .atomic)
  print("\(relativePath): \(size)x\(size)")
}

let iOS: [(String, Int)] = [
  ("Icon-App-20x20@1x.png", 20),
  ("Icon-App-20x20@2x.png", 40),
  ("Icon-App-20x20@3x.png", 60),
  ("Icon-App-29x29@1x.png", 29),
  ("Icon-App-29x29@2x.png", 58),
  ("Icon-App-29x29@3x.png", 87),
  ("Icon-App-40x40@1x.png", 40),
  ("Icon-App-40x40@2x.png", 80),
  ("Icon-App-40x40@3x.png", 120),
  ("Icon-App-50x50@1x.png", 50),
  ("Icon-App-50x50@2x.png", 100),
  ("Icon-App-57x57@1x.png", 57),
  ("Icon-App-57x57@2x.png", 114),
  ("Icon-App-60x60@2x.png", 120),
  ("Icon-App-60x60@3x.png", 180),
  ("Icon-App-72x72@1x.png", 72),
  ("Icon-App-72x72@2x.png", 144),
  ("Icon-App-76x76@1x.png", 76),
  ("Icon-App-76x76@2x.png", 152),
  ("Icon-App-83.5x83.5@2x.png", 167),
  ("Icon-App-1024x1024@1x.png", 1024),
]

let macOS: [(String, Int)] = [
  ("app_icon_16.png", 16),
  ("app_icon_32.png", 32),
  ("app_icon_64.png", 64),
  ("app_icon_128.png", 128),
  ("app_icon_256.png", 256),
  ("app_icon_512.png", 512),
  ("app_icon_1024.png", 1024),
]

do {
  try render(
    image: vector,
    size: 1024,
    to: "assets/branding/musik-app-icon.png"
  )
  try render(
    image: vector,
    size: 1024,
    to: "docs/app-icon-1024.png"
  )
  try render(
    image: splashVector,
    size: 1024,
    to: "assets/branding/splash-mark.png",
    opaque: false
  )
  for (name, size) in iOS {
    try render(
      image: vector,
      size: size,
      to: "ios/Runner/Assets.xcassets/AppIcon.appiconset/\(name)"
    )
  }
  for (name, size) in macOS {
    try render(
      image: vector,
      size: size,
      to: "macos/Runner/Assets.xcassets/AppIcon.appiconset/\(name)"
    )
  }
} catch {
  fputs("Icon rendering failed: \(error)\n", stderr)
  exit(1)
}
