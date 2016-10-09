//
//  ViewController.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, ActionDelegate {//SubVCのためにActionDelegateプロトコルに準拠
    
    /* === メンバ === */
    
    var bingoData = BingoDataEntity()
    //var chanceValue = 0
    var stopCount = 0
    var timer : NSTimer!
    var preFrame : NSRect!
    
    
    /* === メソッド === */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Do any additional setup after loading the view. */
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
        timer.invalidate()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    //数字に対応した画像を表示する
    func displayCurrentNum(num: Int) -> Void {
        imageCurrentNum.image = NSImage(named: num.description + ".png")
    }
    
    //タイマー用
    func shuffleRoulette(timer: NSTimer) {
        let shuffleNumber = Int(arc4random_uniform(UInt32(bingoData.maxNum))) + 1
        displayCurrentNum(shuffleNumber)
    }
    
    //タイマー用
    func stopRoulette(timer: NSTimer) {
        let shuffleNumber = Int(arc4random_uniform(UInt32(bingoData.maxNum))) + 1
        displayCurrentNum(shuffleNumber)

        stopCount += 1
        if stopCount >= 3 {
            timer.invalidate()
            let nextNum = bingoData.outputNextNum()
            displayCurrentNum(nextNum)
            
            preFrame = imageCurrentNum.frame
            stopCount = -15
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.animation2(_:)), userInfo: nil, repeats: true)
            renewPastNums(nextNum)
        }
    }
    
    //なめらかグーン(timer0.05)
    func animation1(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount <= 0 {
            return
        }
        if stopCount < 6 {
            changeSize(CGFloat(10-stopCount), preFrame: preFrame)
        } else if stopCount < 11 {
            changeSize(CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 16 {
            changeSize(CGFloat(20-stopCount), preFrame: preFrame)
        } else if stopCount < 21 {
            changeSize(CGFloat(stopCount-10), preFrame: preFrame)
        } else if stopCount < 26 {
            changeSize(CGFloat(30-stopCount), preFrame: preFrame)
        } else if stopCount < 31 {
            changeSize(CGFloat(stopCount-20), preFrame: preFrame)
        } else {
            timer.invalidate()
        }
    }
    
    //ピカピカピカピカ(timer0.05)
    func animation2(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount <= 0 {
            return
        }
        if stopCount % 2 == 0 {
            changeSize(CGFloat(9.75), preFrame: preFrame)
        } else {
            changeSize(CGFloat(10), preFrame: preFrame)
        }
        if stopCount > 30 {
            changeSize(CGFloat(10), preFrame: preFrame)
            timer.invalidate()
        }
    }
    
    //BINGO用(timer0.05)
    func animation3(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount <= 0 {
            return
        }
        if stopCount < 18 {
            imageCurrentNum.hidden = false
            changeSize(CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 25 {
            changeSize(CGFloat(34 - stopCount), preFrame: preFrame)
        } else if stopCount < 32 {
            changeSize(CGFloat(stopCount - 14), preFrame: preFrame)
        } else if stopCount < 39 {
            changeSize(CGFloat(48 - stopCount), preFrame: preFrame)
        } else if stopCount < 46 {
            changeSize(CGFloat(stopCount - 28), preFrame: preFrame)
        } else if stopCount < 53 {
            changeSize(CGFloat(62 - stopCount), preFrame: preFrame)
        } else {
            timer.invalidate()
        }
    }

    
    func changeSize(rate: CGFloat, preFrame: NSRect) -> Void {
        let width = preFrame.width * rate / 10
        let heigt = preFrame.height * rate / 10
        let x = preFrame.origin.x + (preFrame.width - width) / 2
        let y = preFrame.origin.y + (preFrame.height - heigt) / 2
        imageCurrentNum.setFrameSize(CGSize(width: width, height: heigt))
        imageCurrentNum.setFrameOrigin(NSPoint(x:  x, y: y))
        imageCurrentNum.setNeedsDisplay()
    }
    
    //SubVCを呼びだす直前の動作
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let subVC = segue.destinationController as! SubVC
        subVC.delegate = self
    }
    
    //数字履歴表示更新
    func renewPastNums(num: Int) -> Void {
        //編集のためbitmapに変換
        let bmap = NSBitmapImageRep(data: imagePastNums.image!.TIFFRepresentation!)
    
        let place = BingoDataModel.getPlace(num)
        
        for x in place.startX...place.endX {
            for y in place.startY...place.endY {
                //該当箇所を透明色に
                bmap!.setColor(NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
        
        imagePastNums.image = NSImage(data: (bmap?.TIFFRepresentation)!)
    }
    
    /* === デリゲートメソッド: ActionDelegate === */
    //ビンゴ進行処理
    func takeAction() -> Void {
        if timer.valid {
            timer.invalidate()
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.stopRoulette(_:)), userInfo: nil, repeats: true)
            stopCount = 0
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
        }
    }
    //好きな数字処理
    func favoriteNum(favorite: Int) -> Void {
        if favorite > 0 {
            if bingoData.favoriteNum(favorite) {
                //labelMain.stringValue = bingoData.outputNextNum()
                //labelSub.stringValue = bingoData.outputPastNums()
            }
        }
    }
    
    func bingo() -> Void {
        imageCurrentNum.hidden = true
        imageCurrentNum.image = NSImage(named: "BINGO.png")
        preFrame = imageCurrentNum.frame
        stopCount = 0
        timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.animation3(_:)), userInfo: nil, repeats: true)
    }
    
    
    /* === インタフェースビルダー === */
    
    @IBOutlet weak var imageCurrentNum: NSImageView!
    
    @IBOutlet weak var imagePastNums: NSImageView!
    
    
    
    /*旧コード
     @IBOutlet weak var labelMain: NSTextField!
     
     @IBOutlet weak var labelSub: NSTextField!
     
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
    }*/
}

