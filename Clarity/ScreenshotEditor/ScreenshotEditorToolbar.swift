//
//  ScreenshotEditorToolbar.swift
//  Clarity
//
//  Created by Johan Novak on 5/15/22.
//
import AppKit

public class ToolbarButton: NSButton {
    @IBInspectable var bgColor: NSColor = NSColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.1)
    @IBInspectable var foreColor: NSColor = .black
    @IBInspectable var highlightColor: NSColor = NSColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.2)
    @IBInspectable var cornerRadius: CGFloat = 15
    @IBInspectable var verticalImagePadding: CGFloat = 5
    @IBInspectable var horizontalImagePadding: CGFloat = 5
    
    func configure() {
        // Set the proper background color depending on
        // whether the button is highlighted or not.
        if !isHighlighted {
            self.layer?.backgroundColor = bgColor.cgColor
        } else {
            self.layer?.backgroundColor = highlightColor.cgColor
        }
        
        // Create an attributed string using the
        // provided title color, and use that attributed
        // string as title.
        let attributedString = NSAttributedString(string: title,
                                                  attributes: [NSAttributedString.Key.foregroundColor: foreColor])
        self.attributedTitle = attributedString
        
        // Set the corner radius.
        self.layer?.cornerRadius = cornerRadius
    }
    
    public override func draw(_ dirtyRect: NSRect) {
        let originalBounds = self.bounds
        defer { self.bounds = originalBounds }
        
        self.bounds = originalBounds.insetBy(
            dx: horizontalImagePadding,
            dy: verticalImagePadding
        )
        
        
        super.draw(dirtyRect)
        configure()
    }
}


class ScreenshotEditorToolbar: NSView {
    var toolbarHidden: Bool = true
    @IBOutlet weak var upConstraint: NSLayoutConstraint!
    
    required init?(coder:NSCoder) {
        super.init(coder:coder)
    }
    
    func showToolbar() {
        toolbarHidden = false
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            
            self.upConstraint.animator().constant = -75
        })
    }
    
    func hideToolbar() {
        toolbarHidden = true
        
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
            
            self.upConstraint.animator().constant = 50
        })
    }
}
