//
//  ViewController.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Daijiro Fukuda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    var bingoData : BingoDataEntity = BingoDataEntity()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var labelMain: NSTextField!

    @IBOutlet weak var labelSub: NSTextField!
    
    @IBOutlet weak var numField: NSTextField!
    
    @IBAction func buttonMain(sender: AnyObject) {
        labelMain.stringValue = bingoData.outputNextNum()
        labelSub.stringValue = bingoData.outputPastNums()
    }
    
    @IBAction func buttonFavorite(sender: AnyObject) {
        let favorite = Int(numField.stringValue)
        if favorite > 0 {
            if bingoData.favoriteNum(favorite!) {
                labelMain.stringValue = bingoData.outputNextNum()
                labelSub.stringValue = bingoData.outputPastNums()
            }
        }
    }
}

