//
//  ScreenshotEditorCanvas.swift
//  Clarity
//
//  Created by Johan Novak on 5/15/22.
//

import Foundation
import CoreGraphics
import AppKit

extension CGAffineTransform {
    static func flippingVertically(_ height: CGFloat) -> CGAffineTransform {
        var transform = CGAffineTransform(scaleX: 1, y: -1)
        transform = transform.translatedBy(x: 0, y: -height)
        return transform
    }
}

extension NSImage {
    func cropping(to originalRect: CGRect, flipped: Bool = false) -> NSImage {
        var rect = originalRect
        
        if flipped {
            rect = rect.applying(CGAffineTransform.flippingVertically(self.size.height))
        }
        
        var imageRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let imageRef = self.cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
            return NSImage(size: rect.size)
        }
        guard let crop = imageRef.cropping(to: rect) else {
            return NSImage(size: rect.size)
        }
        return NSImage(cgImage: crop, size: NSZeroSize)
    }
}

extension NSAffineTransform {
    func transform(_ aRect: NSRect) -> NSRect {
        var clone = aRect
        clone.origin = transform(clone.origin)
        clone.size = transform(clone.size)
        return clone
    }
}

func invertRect(rect: CGRect, width: CGFloat, height: CGFloat) -> [CGRect] {
    return [
        CGRect(x: 0, y: 0, width: width, height: rect.minY),
        CGRect(x: 0, y: rect.maxY, width: width, height: height - rect.maxY),
        CGRect(x: 0, y: rect.minY, width: rect.minX, height: rect.height),
        CGRect(x: rect.maxX, y: rect.minY, width: width - rect.maxX, height: rect.height)
    ]
}


class ScreenshotCanvasLayer: CALayer {
    var baseImage: NSImage?
    var screenshotRect: NSRect?
    var screenshotMode: ScreenshotType = .rect
    
    override func draw(in context: CGContext) {
        let priorNsgc = NSGraphicsContext.current
        defer { NSGraphicsContext.current = priorNsgc }
        let nsContext = NSGraphicsContext(cgContext: context, flipped: false)
        nsContext.imageInterpolation = NSImageInterpolation.low
        NSGraphicsContext.current = nsContext
        
        baseImage!.draw(in: bounds)
        
        if screenshotRect != nil {
            context.setFillColor(.init(red: 0, green: 0, blue: 0, alpha: 0.5))
            context.setStrokeColor(CGColor.init(red: 1, green: 1, blue: 1, alpha: 0.9))
            context.addRects(invertRect(rect: screenshotRect!, width: CGFloat(context.width), height: CGFloat(context.height)))
            context.drawPath(using: .fill)
            context.addRect(screenshotRect!.insetBy(dx: -1, dy: -1))
            context.drawPath(using: .stroke)
        } else if screenshotMode == .rect {
            context.setFillColor(.init(red: 0, green: 0, blue: 0, alpha: 0.5))
            context.addRect(CGRect(x: 0, y: 0, width: context.width, height: context.height))
            context.drawPath(using: .fillStroke)
        }
    }
    
    init(baseImage: NSImage) {
        self.baseImage = baseImage
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func into_image(display: NSScreen) -> NSImage {
        print("Started processing Image")
        let transform = NSAffineTransform()
        transform.scale(by: display.backingScaleFactor)
        
        var image = baseImage!
        
        if screenshotRect != nil && screenshotMode == .rect {
            var newScreenshotRect = screenshotRect!
            image = image.cropping(to: transform.transform(newScreenshotRect), flipped: true)
        }
        
        return image
    }
}

class ScreenshotCanvasView: NSView {
    var editorLayer: ScreenshotCanvasLayer?
    var screenshotType: ScreenshotType = ScreenshotType.rect
    var rectAreaSelection: NSRect?
    var rectAreaSelected: Bool = false
    var lastPress: NSPoint?
    var onRectSelect: (() -> Void)?
    var isDragging: Bool = false
    var trackingArea : NSTrackingArea?
    var mainDisplay: NSScreen?
    
    func into_image() -> NSImage {
        return editorLayer!.into_image(display: mainDisplay!)
    }
    
    override func cursorUpdate(with event: NSEvent) {
        if screenshotType == .rect && !rectAreaSelected {
            NSCursor.crosshair.set()
        } else {
            NSCursor.arrow.set()
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if trackingArea != nil {
            removeTrackingArea(trackingArea!)
        }
        let aTrackingArea = NSTrackingArea(rect: bounds, options: [.cursorUpdate, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(aTrackingArea)
        self.trackingArea = aTrackingArea
    }
    
    func setScreenshotType(type: ScreenshotType, shouldResetCursor: Bool = false) {
        screenshotType = type
        editorLayer?.screenshotMode = type
        editorLayer!.setNeedsDisplay()
    }
    
    override func mouseDown(with event: NSEvent) {
        lastPress = event.locationInWindow
    }
    
    override func mouseUp(with event: NSEvent) {
        isDragging = false
        if (screenshotType == .rect && !rectAreaSelected) {
            if Int(self.rectAreaSelection!.width) + Int(self.rectAreaSelection!.height) > 10 {
                self.rectAreaSelected = true
                isDragging = false
                print("Finished Drag")
                onRectSelect?()
            } else {
                self.rectAreaSelection = nil
                self.editorLayer?.screenshotRect = nil
                self.editorLayer?.setNeedsDisplay()
            }
        }
    }
    
    override func mouseDragged(with event: NSEvent) {
        isDragging = true
        if (screenshotType == .rect && !rectAreaSelected && lastPress != nil) {
            rectAreaSelection = NSRect(origin: lastPress!, size: NSSize(width: event.locationInWindow.x - lastPress!.x, height: event.locationInWindow.y - lastPress!.y))
            editorLayer!.screenshotRect = rectAreaSelection
            editorLayer!.setNeedsDisplay()
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setImage(im:NSImage) {
        editorLayer = ScreenshotCanvasLayer(baseImage:im)
        self.wantsLayer = true
        self.layer = self.editorLayer
        editorLayer!.setNeedsDisplay()
    }
}
