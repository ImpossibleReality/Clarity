//
//  ShortcutControl.swift
//  Clarity
//
//  Created by Johan Novak on 5/8/22.
//

import Foundation
import Cocoa
import KeyboardShortcuts

final class ShortcutControl: NSView {
    public required init?(coder:NSCoder) {
        let recorder = KeyboardShortcuts.RecorderCocoa(for: .takeScreenshot)
        
        super.init(coder:coder)
        super.addSubview(recorder)
    }
}
