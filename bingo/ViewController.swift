//
//  ViewController.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, ActionDelegate {//SubVCのためにActionDelegateプロトコルに準拠
    
    var bingoData : BingoDataEntity = BingoDataEntity()
    var chanceValue = 0
    var stopCount = 0
    var timer : NSTimer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Do any additional setup after loading the view. */
        self.numField.hidden = true
        //self.buttonFavorite.hideen = false
        //画像を設定する
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
        timer.invalidate()
        labelMain.stringValue = "START"
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //SubVCを呼びだす直前の動作
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let subVC = segue.destinationController as! SubVC
        subVC.delegate = self
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
    
    func shuffleRoulette(timer: NSTimer) {
        let shuffleNumber = arc4random_uniform(10) + 1
        labelMain.stringValue = shuffleNumber.description
    }
    
    func stopRoulette(timer: NSTimer) {
        let shuffleNumber = arc4random_uniform(10) + 1
        labelMain.stringValue = shuffleNumber.description
        stopCount += 1
        if stopCount >= 3 {
            timer.invalidate()
            labelMain.stringValue = bingoData.outputNextNum()
            labelSub.stringValue = bingoData.outputPastNums()
        }
    }

    
    /* === デリゲートメソッド: ActionDelegate === */
    //ビンゴ進行処理
    func takeAction() -> Void {
        if timer.valid {
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.stopRoulette(_:)), userInfo: nil, repeats: true)
            stopCount = 0
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
        }
        
        labelMain.stringValue = bingoData.outputNextNum()
        labelSub.stringValue = bingoData.outputPastNums()
    }
}

