//
//  ViewController.swift
//  Clarity
//
//  Created by Johan Novak on 5/7/22.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
        self.view.wantsLayer = true
        self.view.alphaValue = 0.5
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

