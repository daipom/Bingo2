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
    var chanceValue = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.numField.hidden = true
        //self.buttonFavorite.hideen = false
        //画像を設定する
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBOutlet weak var labelMain: NSTextField!

    @IBOutlet weak var labelSub: NSTextField!
    
    @IBOutlet weak var numField: NSTextField!
    
    @IBOutlet weak var chanceImage: NSImageView!
    
    @IBAction func buttonMain(sender: AnyObject) {
        chanceValue = (Int)(arc4random_uniform(5))
        
        if chanceValue == 0{
            self.numField.hidden = false
            //self.buttonFavorite.hidden = false
            labelMain.stringValue = "Chance!"
            //写真を出す
            let myImage = NSImage(named: "testimage.png")
            chanceImage.image = myImage
        }
        else{
            labelMain.stringValue = bingoData.outputNextNum()
            labelSub.stringValue = bingoData.outputPastNums()
        }
    }
    
    @IBAction func buttonFavorite(sender: AnyObject) {
        let favorite = Int(numField.stringValue)
        if favorite > 0 {
            if bingoData.favoriteNum(favorite!) {
                labelMain.stringValue = bingoData.outputNextNum()
                labelSub.stringValue = bingoData.outputPastNums()
            }
        }
        self.numField.hidden = false
        //self.buttonFavorite.hidden = false
        //写真を隠す
    }
}

