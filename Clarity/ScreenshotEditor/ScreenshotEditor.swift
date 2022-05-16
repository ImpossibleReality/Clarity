//
//  ScreenshotEditor.swift
//  Clarity
//
//  Created by Johan Novak on 5/7/22.
//

import Cocoa
import CoreGraphics
import SwiftImage
import Carbon

public enum ScreenshotType {
    case screen
    case rect
}

func writeImageToClipboard(img: NSImage)
{
    let pb = NSPasteboard.general
    pb.clearContents()
    pb.writeObjects([img])
}

public func takeScreenshot(_ display: CGDirectDisplayID = CGMainDisplayID()) -> NSImage {
    let image = CGDisplayCreateImage(display)
    
    return NSImage(cgImage: image!, size: NSZeroSize)
}

final class ScreenshotEditor: NSView, NibLoadable {
    @IBOutlet var mainCanvas: ScreenshotCanvasView!
    @IBOutlet var mainToolbar: ScreenshotEditorToolbar!
    @IBOutlet var screenshotTypeButton: NSButton!
    var hasSelected: Bool = false
    var canFinishSlection: Bool = false
    
    func setup() {
        mainCanvas.onRectSelect = { () in
            self.mainToolbar.showToolbar()
            self.hasSelected = true
            self.screenshotTypeButton.isHidden = true
        }
        
        if mainCanvas.screenshotType == .rect {
            NSCursor.crosshair.push()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            /* guard let im = mainCanvas.editorLayer?.into_image() else {
             self.exitFullScreenMode()
             self.window?.close()
             return
             }
             print("Writing to clipboard")
             writeImageToClipboard(img: im) */
            
            self.exitFullScreenMode()
            self.window?.close()
        } else if event.keyCode == UInt16(kVK_Return) {
            self.exitFullScreenMode()
            self.window?.close()
            
            let im = mainCanvas.into_image()
            
            
            print("Writing to clipboard")
            writeImageToClipboard(img: im)
        } else if event.keyCode == UInt16(kVK_UpArrow) {
            mainToolbar.showToolbar()
        } else if event.keyCode == UInt16(kVK_Space) {
            if !hasSelected && !mainCanvas.isDragging {
                switch mainCanvas.screenshotType {
                case .rect: do {
                    mainCanvas.setScreenshotType(type: .screen, shouldResetCursor: true)
                    self.screenshotTypeButton.image = NSImage(systemSymbolName: "display", accessibilityDescription: nil)
                    self.canFinishSlection = true
                    self.mainToolbar.showToolbar()
                }
                case .screen: do {
                    self.mainToolbar.hideToolbar()
                    mainCanvas.setScreenshotType(type: .rect)
                    self.screenshotTypeButton.image = NSImage(systemSymbolName: "rectangle.dashed", accessibilityDescription: nil)
                }
                }
            }
        }
    }
}

public class ScreenshotEditorManager {
    var image: NSImage
    var screenshotEditorView: ScreenshotEditor
    var mainWindowController: NSWindowController
    var mainViewController: NSViewController
    var mainDisplay: NSScreen
    
    
    init(im:NSImage, display: NSScreen) {
        image = im
        
        mainDisplay = display
        
        screenshotEditorView = ScreenshotEditor.createFromNib()!
        
        screenshotEditorView.mainCanvas.setImage(im: im)
        screenshotEditorView.mainCanvas.mainDisplay = display
        
        mainViewController = NSViewController()
        mainViewController.view = screenshotEditorView
        
        mainWindowController = NSWindowController()
        
        screenshotEditorView.mainToolbar?.layer?.cornerRadius = 25
        screenshotEditorView.mainToolbar?.upConstraint.constant = 50
        
        screenshotEditorView.setup()
        
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        let window = NSWindow(contentViewController:mainViewController)
        mainWindowController.window = window
        
        
        let presOptions: NSApplication.PresentationOptions = ([.hideMenuBar
                                                               ,.hideDock, .disableAppleMenu, .disableForceQuit, .disableProcessSwitching, .disableSessionTermination ])
        let optionsDictionary =
        [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
            NSNumber(value: presOptions.rawValue), NSView.FullScreenModeOptionKey.fullScreenModeWindowLevel : NSNumber(value: NSWindow.Level.screenSaver.rawValue)]
        
        mainWindowController.window?.contentView?.enterFullScreenMode(display, withOptions: optionsDictionary)
        
        mainWindowController.window!.contentView!.window!.makeFirstResponder(mainWindowController.window!.contentView!)
        
        mainWindowController.window!.contentView!.window!.makeKey()
    }
}
