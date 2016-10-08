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
            renewPastNums(nextNum)
        }
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

