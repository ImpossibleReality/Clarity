//
//  AppDelegate.swift
//  Clarity
//
//  Created by Johan Novak on 5/7/22.
//

import Cocoa
import KeyboardShortcuts

var statusItem: NSStatusItem?

extension KeyboardShortcuts.Name {
    static let takeScreenshot = Self("takeScreenshot", default: KeyboardShortcuts.Shortcut.init(.s, modifiers: [.command, .option]))
}

extension NSScreen {
  var displayID: CGDirectDisplayID {
      return deviceDescription[NSDeviceDescriptionKey(rawValue: "NSScreenNumber")] as? CGDirectDisplayID ?? 0
  }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var menu: NSMenu?
    @IBOutlet weak var displayWindowController: DisplayWindow?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        KeyboardShortcuts.enable(.takeScreenshot)
        
        KeyboardShortcuts.onKeyUp(for: .takeScreenshot) { [self] in
            screenshotItemClick(_sender: nil)
        }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        let itemImage = NSImage(named: "TrayIcon")
        itemImage?.isTemplate = true
        statusItem?.button?.image = itemImage
        statusItem?.menu = menu
        
    }
    
    @IBAction func screenshotItemClick(_sender: NSMenuItem?) {
        print("Taking Screenshot")
        guard let display = NSScreen.main else {
            return
        }
        
        let image = takeScreenshot(display.displayID)
        
        let manager = ScreenshotEditorManager(im:image, display: display)
        print("Showed Window")
    }
}

