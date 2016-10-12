//
//  ViewController.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa
import AudioToolbox

class ViewController: NSViewController, ActionDelegate {//SubVCのためにActionDelegateプロトコルに準拠
    
    /* === メンバ === */
    
    var bingoData = BingoDataEntity()
    var stopCount = 0
    var timer : NSTimer!
    var preFrame : NSRect!  //アニメーションの時に、イメージの元の状態を記憶しておくのに用いる
    var subVC : SubVC!  //コントロールウィンドウの制御オブジェクトへアクセスするため
    var openingTimer: NSTimer!  //オープニング時アニメーション用タイマー
    var currentAngle: CGFloat = 0  //回転アニメーション用に現在の回転角を保存
    
    /* === メソッド === */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Do any additional setup after loading the view. */
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
        timer.invalidate()
        
        /*数字履歴シート一部透明化*/
        let bmap = NSBitmapImageRep(data: imagePastNums.image!.TIFFRepresentation!)
        let bmap2 = NSBitmapImageRep(data: imagePastNumsRed.image!.TIFFRepresentation!)
        for x in 541...1190 {
            for y in 14...517 {
                //該当箇所を透明色に
                bmap!.setColor(NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                bmap2!.setColor(NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
        for x in 672...1059 {
            for y in 518...618 {
                //該当箇所を透明色に
                bmap!.setColor(NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
                bmap2!.setColor(NSColor.init(calibratedRed: 0, green: 0, blue: 0, alpha: 0), atX: x, y: y)
            }
        }
        imagePastNums.image = NSImage(data: (bmap?.TIFFRepresentation)!)
        imagePastNumsRed.image = NSImage(data: (bmap2?.TIFFRepresentation)!)
        
        /*オープニングアニメーション*/
        openingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.animationOpening(_:)), userInfo: nil, repeats: true)
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
    
    //タイマー用 高速処理
    func shuffleRoulette(timer: NSTimer) {
        let shuffleNumber = Int(arc4random_uniform(UInt32(bingoData.maxNum))) + 1
        displayCurrentNum(shuffleNumber)
        //音を出す
        ringShuffleSound("pi")
    }
    
    //タイマー用 スロー処理
    func stopRoulette(timer: NSTimer) {
        stopCount += 1
        
        if !bingoData.isNextEvent() {   //デフォルト
            let shuffleNumber = Int(arc4random_uniform(UInt32(bingoData.maxNum))) + 1
            displayCurrentNum(shuffleNumber)
            
            //音を出す
            if stopCount <= 2 {  //デン！と一緒にスネアを鳴らしたくないので
                ringShuffleSound("pi")
            }
            
            if stopCount >= 3 {
                timer.invalidate()
                actionAtNumDecided()
            }
        } else {    //イベント処理
            //画像処理
            if bingoData.eventName[bingoData.eventKind].containsString("FJB") || bingoData.eventName[bingoData.eventKind].containsString("五十嵐顧問") {
                //写真が一枚しかない人用処理
                if stopCount < 4 {
                    let shuffleNumber = Int(arc4random_uniform(UInt32(bingoData.maxNum))) + 1
                    imageEvent.image = NSImage(named: shuffleNumber.description + ".png")
                    //displayCurrentNum(shuffleNumber) //窓透明化のためCurrentNumViewはいじれない
                } else {
                    imageEvent.image = NSImage(named: bingoData.eventName[bingoData.eventKind] + ".jpg")
                }
            } else {
                //写真が4枚ある人用処理
                imageEvent.image = NSImage(named: bingoData.eventName[bingoData.eventKind] + stopCount.description + ".jpg")
            }
            //音
            if stopCount < 4 {
                ringShuffleSound("pi")
            }
            
            if stopCount >= 4 {
                //写真拡大アニメーションへ
                timer.invalidate()
                preFrame = imageEvent.frame
                stopCount = -10
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(ViewController.animation4(_:)), userInfo: nil, repeats: true)
                //音
                ringShuffleSound("stop")
            }
        }
    }
    
    //決定数字を表示する時の処理
    func actionAtNumDecided() -> Void {
        let nextNum = bingoData.outputNextNum()
        displayCurrentNum(nextNum)
        changeBlueToRed()
        
        preFrame = imageCurrentNum.frame
        stopCount = -15
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.animation2(_:)), userInfo: nil, repeats: true)
        renewPastNums(nextNum)
        
        //デン！
        ringShuffleSound("stop")
    }
    
    //音出力
    func ringShuffleSound(soundFileName: String) {
        var soundIDRing:SystemSoundID = 1
        let soundUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundFileName, ofType: "mp3")!)
        AudioServicesCreateSystemSoundID(soundUrl, &soundIDRing)    //参照した音声ファイルからIDを作成
        AudioServicesPlaySystemSound(soundIDRing)   //作成したIDから音声を再生する
    }
    
    //イベント時窓切り抜き
    func eventWindow(event: Bool) -> Void {
        let bmap = NSBitmapImageRep(data: imageCurrentNum.image!.TIFFRepresentation!)
        let bmap2 = NSBitmapImageRep(data: imageBackground.image!.TIFFRepresentation!)
        
        var alpha: CGFloat = 0
        if event {
            alpha = 0
        } else {
            alpha = 1
        }
        //currentNum切り抜き
        var center = (x: 295, y: 295)
        var radius = 240
        for x in center.x-radius...center.x {
            for y in center.y-radius...center.y {
                if (x-center.x)*(x-center.x) + (y-center.y)*(y-center.y) < radius*radius {
                    BingoDataModel.setAlpha(bmap!, x: x, y: y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap!, x: 2*center.x-x, y: y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap!, x: x, y: 2*center.y-y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap!, x: 2*center.x-x, y: 2*center.y-y, alpha: alpha)
                }
            }
        }
        //background切り抜き
        center = (565, 430)
        radius = 170
        for x in center.x-radius...center.x {
            for y in center.y-radius...center.y {
                if (x-center.x)*(x-center.x) + (y-center.y)*(y-center.y) < radius*radius {
                    BingoDataModel.setAlpha(bmap2!, x: x, y: y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap2!, x: 2*center.x-x, y: y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap2!, x: x, y: 2*center.y-y, alpha: alpha)
                    BingoDataModel.setAlpha(bmap2!, x: 2*center.x-x, y: 2*center.y-y, alpha: alpha)
                }
            }
        }
        
        imageCurrentNum.image = NSImage(data: (bmap?.TIFFRepresentation)!)
        imageBackground.image = NSImage(data: (bmap2?.TIFFRepresentation)!)
    }
    
    //currentImage回転(オープニングアニメーション)
    func animationOpening(timer: NSTimer) -> Void {
        imageCurrentNum.rotateByAngle(10)
        imageCurrentNum.setNeedsDisplay()
        currentAngle += 10
        if currentAngle > 360 {
            currentAngle -= 360
        }
    }
    
    //なめらかグーン(未使用)
    func animation1(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount <= 0 {
            return
        }
        if stopCount < 6 {
            changeSize(imageCurrentNum, rate: CGFloat(10-stopCount), preFrame: preFrame)
        } else if stopCount < 11 {
            changeSize(imageCurrentNum, rate: CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 16 {
            changeSize(imageCurrentNum, rate: CGFloat(20-stopCount), preFrame: preFrame)
        } else if stopCount < 21 {
            changeSize(imageCurrentNum, rate: CGFloat(stopCount-10), preFrame: preFrame)
        } else if stopCount < 26 {
            changeSize(imageCurrentNum, rate: CGFloat(30-stopCount), preFrame: preFrame)
        } else if stopCount < 31 {
            changeSize(imageCurrentNum, rate: CGFloat(stopCount-20), preFrame: preFrame)
        } else {
            timer.invalidate()
        }
    }
    
    //ピカピカピカピカピカ(数字決定時)
    func animation2(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount < 0 {
            return
        }
        if stopCount % 2 == 0 {
            changeSize(imageCurrentNum, rate: CGFloat(9.75), preFrame: preFrame)
        } else {
            changeSize(imageCurrentNum, rate: CGFloat(10), preFrame: preFrame)
        }
        if stopCount > 30 {
            changeSize(imageCurrentNum, rate: CGFloat(10), preFrame: preFrame)
            timer.invalidate()
            //UI制御
            subVC.buttonNext.enabled = true
            subVC.buttonBingo.enabled = true
            subVC.popUpNumsRemained.enabled = true
            subVC.popUpEventKind.enabled = true
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
            changeSize(imageCurrentNum, rate: CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 25 {
            changeSize(imageCurrentNum, rate: CGFloat(34 - stopCount), preFrame: preFrame)
        } else if stopCount < 32 {
            changeSize(imageCurrentNum, rate: CGFloat(stopCount - 14), preFrame: preFrame)
        } else if stopCount < 39 {
            changeSize(imageCurrentNum, rate: CGFloat(48 - stopCount), preFrame: preFrame)
        } else if stopCount < 46 {
            changeSize(imageCurrentNum, rate: CGFloat(stopCount - 28), preFrame: preFrame)
        } else if stopCount < 53 {
            changeSize(imageCurrentNum, rate: CGFloat(62 - stopCount), preFrame: preFrame)
        } else {
            timer.invalidate()
            //UI制御
            subVC.buttonNext.enabled = true
            subVC.buttonBingo.enabled = true
            subVC.popUpEventKind.enabled = true
            subVC.popUpNumsRemained.enabled = true
        }
    }
    
    //Eventイメージ拡大　favoriteボタンまでこのまま
    func animation4(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount >= 0 {
            if stopCount == 0 {
                //最前面へ
                var subviews = self.view.subviews
                subviews.append(subviews[0])
                subviews.removeAtIndex(0)
                self.view.subviews = subviews
            }
            if stopCount < 11 {
                let rate: CGFloat = CGFloat(stopCount)
                let width = preFrame.width + (self.view.frame.width - preFrame.width) * rate / 10
                let heigt = preFrame.height + (self.view.frame.height - preFrame.height) * rate / 10
                let x = preFrame.origin.x + (0 - preFrame.origin.x) * rate / 10
                let y = preFrame.origin.y + (0 - preFrame.origin.y) * rate / 10
                imageEvent.setFrameSize(CGSize(width: width, height: heigt))
                imageEvent.setFrameOrigin(NSPoint(x:  x, y: y))
                imageEvent.setNeedsDisplay()
            } else {
                timer.invalidate()
                //UI制御
                subVC.buttonFavorite.enabled = true
                subVC.popUpNumsRemained.enabled = true
            }
        }
    }
    
    //Eventイメージ縮小　favorite処理
    func animation5(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount < 11 {
            let rate: CGFloat = CGFloat(stopCount)
            let width = self.view.frame.width + (preFrame.width - self.view.frame.width) * rate / 10
            let heigt = self.view.frame.height + (preFrame.height - self.view.frame.height) * rate / 10
            let x = 0 + (preFrame.origin.x - 0) * rate / 10
            let y = 0 + (preFrame.origin.y - 0) * rate / 10
            imageEvent.setFrameSize(CGSize(width: width, height: heigt))
            imageEvent.setFrameOrigin(NSPoint(x:  x, y: y))
            imageEvent.setNeedsDisplay()
        } else if stopCount == 11 {
            //最背面へ
            var subviews = self.view.subviews
            subviews.insert(subviews[5], atIndex: 0)
            subviews.removeLast()
            self.view.subviews = subviews
        } else if stopCount < 21 {
        } else {
            timer.invalidate()
            //透明化解除して数字決定処理へ
            eventWindow(false)
            actionAtNumDecided()
        }
    }
    
    //NSViewサイズ変更
    func changeSize(imageView: NSImageView, rate: CGFloat, preFrame: NSRect) -> Void {
        let width = preFrame.width * rate / 10
        let heigt = preFrame.height * rate / 10
        let x = preFrame.origin.x + (preFrame.width - width) / 2
        let y = preFrame.origin.y + (preFrame.height - heigt) / 2
        imageView.setFrameSize(CGSize(width: width, height: heigt))
        imageView.setFrameOrigin(NSPoint(x:  x, y: y))
        imageView.setNeedsDisplay()
    }
    func changeSizeToSpecifiedSize(imageView: NSImageView, rate: CGFloat, preFrame: NSRect, goalFrame: NSRect) -> Void {
        let width = preFrame.width + (goalFrame.width - preFrame.width) * rate / 10
        let heigt = preFrame.height + (goalFrame.height - preFrame.height) * rate / 10
        let x = preFrame.origin.x + (preFrame.width - width) / 2
        let y = preFrame.origin.y + (preFrame.height - heigt) / 2
        imageView.setFrameSize(CGSize(width: width, height: heigt))
        imageView.setFrameOrigin(NSPoint(x:  x, y: y))
        imageView.setNeedsDisplay()
    }
    func changeBlueToRed() -> Void {
        let bmap = NSBitmapImageRep(data: imageCurrentNum.image!.TIFFRepresentation!)
        for x in 0...598 {
            for y in 0...581 {
                //青い部分を赤色に
                let color = bmap!.colorAtX(x, y: y)
                if color?.blueComponent > 0.2 && color?.redComponent < 0.5 {
                    bmap!.setColor(NSColor.init(calibratedRed: 1.0, green: 0, blue: 0, alpha: 1.0), atX: x, y: y)
                }
            }
        }
        imageCurrentNum.image = NSImage(data: (bmap?.TIFFRepresentation)!)
    }
    
    //SubVCを呼びだす直前の動作
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let subVC = segue.destinationController as! SubVC
        subVC.delegate = self
        bingoData.subVC = subVC
        self.subVC = subVC
        buttonControle.hidden = true
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
    func takeAction(kind: Int) -> Void {
        //オープニング脱却処理
        if openingTimer.valid {
            openingTimer.invalidate()
            imageCurrentNum.rotateByAngle(-currentAngle)
            subVC.buttonBingo.enabled = true
        }
        //メイン処理
        if timer.valid {
            subVC.buttonNext.enabled = false
            bingoData.eventKind = kind
            timer.invalidate()
            if bingoData.isNextEvent() {//イベント時前処理
                imageEvent.image = imageCurrentNum.image  //一瞬窓が透明になる際のカモフラージュ
                eventWindow(true)   //処理に時間がかかるためtimerがスタートする前に処理
            }
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.stopRoulette(_:)), userInfo: nil, repeats: true)
            stopCount = 0
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(0.09, target: self, selector: #selector(ViewController.shuffleRoulette(_:)), userInfo: nil, repeats: true)
            //UI制御
            subVC.buttonBingo.enabled = false
            subVC.popUpEventKind.enabled = false
            subVC.popUpNumsRemained.enabled = false
        }
    }
    //好きな数字処理
    func favoriteNum(favorite: Int) -> Void {
        subVC.buttonFavorite.enabled = false
        if favorite > 0 {
            if bingoData.favoriteNum(favorite) {
                stopCount = 0
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.animation5(_:)), userInfo: nil, repeats: true)
                //UI制御
                subVC.popUpNumsRemained.enabled = false
            }
        }
    }
    //ビンゴ表示!!
    func bingo() -> Void {
        if !timer.valid {
            imageCurrentNum.hidden = true
            imageCurrentNum.image = NSImage(named: "BINGO.png")
            preFrame = imageCurrentNum.frame
            stopCount = 0
            timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(ViewController.animation3(_:)), userInfo: nil, repeats: true)
            //音
            ringShuffleSound("bingo")
            //UI制御
            subVC.buttonNext.enabled = false
            subVC.buttonBingo.enabled = false
            subVC.popUpEventKind.enabled = false
            subVC.popUpNumsRemained.enabled = false
        }
    }
    
    
    /* === インタフェースビルダー === */
    
    @IBOutlet weak var imageCurrentNum: NSImageView!
    
    @IBOutlet weak var imagePastNums: NSImageView!
    
    @IBOutlet weak var imageEvent: NSImageView!
    
    @IBOutlet weak var imageBackground: NSImageView!
    
    @IBOutlet weak var imagePastNumsRed: NSImageView!
    
    @IBOutlet weak var buttonControle: NSButton!
    
}

