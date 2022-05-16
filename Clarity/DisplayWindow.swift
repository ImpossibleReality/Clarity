//
//  DisplayWindow.swift
//  Clarity
//
//  Created by Johan Novak on 5/8/22.
//

import Foundation
import AppKit

public class DisplayWindow: NSWindowController {
    public func displayImage(im: NSImage) {
        let imageView = self.window?.contentView?.viewWithTag(0) as! NSImageView
        
        imageView.image = im
    }
}
