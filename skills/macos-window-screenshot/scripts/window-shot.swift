#!/usr/bin/env swift
import AppKit
import CoreGraphics
import Foundation
import ImageIO

struct Window: Codable {
    let id: UInt32
    let pid: Int32
    let bundleID: String?
    let appName: String
    let title: String?
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}

func fail(_ message: String) -> Never {
    fputs("[window-shot] ERROR: \(message)\n", stderr)
    exit(2)
}

func option(_ name: String, in args: [String]) -> String? {
    guard let index = args.firstIndex(of: name) else { return nil }
    guard index + 1 < args.count, !args[index + 1].hasPrefix("--") else {
        fail("\(name) requires a value")
    }
    return args[index + 1]
}

func windows() -> [Window] {
    guard let raw = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
        as? [[String: Any]] else {
        fail("cannot enumerate windows; check Screen Recording permission")
    }
    return raw.compactMap { item in
        guard let id = item[kCGWindowNumber as String] as? UInt32,
              let pid = item[kCGWindowOwnerPID as String] as? Int32,
              let layer = item[kCGWindowLayer as String] as? Int, layer == 0,
              let bounds = item[kCGWindowBounds as String] as? [String: Any],
              let width = bounds["Width"] as? Int, width > 0,
              let height = bounds["Height"] as? Int, height > 0 else { return nil }
        let app = NSRunningApplication(processIdentifier: pid)
        return Window(
            id: id, pid: pid, bundleID: app?.bundleIdentifier,
            appName: (item[kCGWindowOwnerName as String] as? String) ?? app?.localizedName ?? "",
            title: item[kCGWindowName as String] as? String,
            x: bounds["X"] as? Int ?? 0, y: bounds["Y"] as? Int ?? 0,
            width: width, height: height
        )
    }
}

func printJSON<T: Encodable>(_ value: T) {
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    guard let data = try? encoder.encode(value), let string = String(data: data, encoding: .utf8) else {
        fail("cannot encode result")
    }
    print(string)
}

let args = Array(CommandLine.arguments.dropFirst())
guard let command = args.first, ["list", "capture"].contains(command) else {
    fail("usage: window-shot.swift list [--bundle-id ID] | capture --window-id ID --bundle-id ID --output PATH [--title EXACT_TITLE]")
}
let found = windows()
if command == "list" {
    let bundleID = option("--bundle-id", in: args)
    printJSON(found.filter { bundleID == nil || $0.bundleID == bundleID })
    exit(0)
}

guard let idText = option("--window-id", in: args), let id = UInt32(idText),
      let bundleID = option("--bundle-id", in: args),
      let output = option("--output", in: args), !output.isEmpty else {
    fail("capture requires --window-id, --bundle-id, and --output")
}
guard let target = found.first(where: { $0.id == id }) else {
    fail("window \(id) is no longer on screen; run list again")
}
guard target.bundleID == bundleID else {
    fail("window \(id) belongs to \(target.bundleID ?? "an unknown app"), expected \(bundleID)")
}
if let expectedTitle = option("--title", in: args), target.title != expectedTitle {
    fail("window \(id) title changed; run list again")
}

let destination = URL(fileURLWithPath: output).standardizedFileURL
let manager = FileManager.default
guard manager.fileExists(atPath: destination.deletingLastPathComponent().path) else {
    fail("output directory does not exist: \(destination.deletingLastPathComponent().path)")
}
guard !manager.fileExists(atPath: destination.path) else {
    fail("output already exists: \(destination.path)")
}
let temporary = destination.deletingLastPathComponent()
    .appendingPathComponent("window-shot-\(UUID().uuidString).png")
defer { try? manager.removeItem(at: temporary) }

let process = Process()
process.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
process.arguments = ["-x", "-o", "-l", String(id), "-t", "png", temporary.path]
do {
    try process.run()
    process.waitUntilExit()
} catch {
    fail("cannot launch screencapture: \(error.localizedDescription)")
}
guard process.terminationStatus == 0,
      let source = CGImageSourceCreateWithURL(temporary as CFURL, nil),
      let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
      image.width > 0, image.height > 0 else {
    fail("screencapture failed or produced no readable image; check Screen Recording permission and window visibility")
}
do {
    try manager.moveItem(at: temporary, to: destination)
} catch {
    fail("cannot save screenshot: \(error.localizedDescription)")
}
struct CaptureResult: Encodable {
    let path: String
    let window: Window
    let imageWidth: Int
    let imageHeight: Int
}
printJSON(CaptureResult(path: destination.path, window: target,
                        imageWidth: image.width, imageHeight: image.height))
