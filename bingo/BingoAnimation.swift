//
//  BingoAnimation.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/10/12.
//  Copyright © 2016年 Daijiro Fukuda. All rights reserved.
//

import Cocoa

class BingoAnimation: NSObject {
    
    /* === メンバ === */
    
    var mainVC:ViewController! = nil
    var stopCount = 0
    var timer : NSTimer!
    var openingTimer: NSTimer!  //オープニング時アニメーション用タイマー
    var currentAngle:CGFloat = 0    //回転アニメーション用に現在の回転角を保存
    var preFrame : NSRect!  //アニメーションの時に、イメージの元の状態を記憶しておくのに用いる
    
    /* === メソッド === */
    
    //コンストラクタ
    init(mainVC:ViewController) {
        self.mainVC = mainVC
    }
    
    //タイマー用 高速処理
    func shuffleRoulette(timer: NSTimer) {
        let shuffleNumber = Int(arc4random_uniform(UInt32(mainVC.bingoData.maxNum))) + 1
        mainVC.displayCurrentNum(shuffleNumber)
        //音を出す
        AnimationSubFunc.ringShuffleSound("pi")
    }
    
    //タイマー用 スロー処理
    func stopRoulette(timer: NSTimer) {
        stopCount += 1
        
        if !mainVC.bingoData.isNextEvent() {   //デフォルト
            let shuffleNumber = Int(arc4random_uniform(UInt32(mainVC.bingoData.maxNum))) + 1
            mainVC.displayCurrentNum(shuffleNumber)
            
            //音を出す
            if stopCount <= 2 {  //デン！と一緒にスネアを鳴らしたくないので
                AnimationSubFunc.ringShuffleSound("pi")
            }
            
            if stopCount >= 3 {
                timer.invalidate()
                actionAtNumDecided()
            }
        } else {    //イベント処理
            //画像処理
            if mainVC.bingoData.eventName[mainVC.bingoData.eventKind].containsString("FJB") || mainVC.bingoData.eventName[mainVC.bingoData.eventKind].containsString("五十嵐顧問") {
                //写真が一枚しかない人用処理
                if stopCount < 4 {
                    let shuffleNumber = Int(arc4random_uniform(UInt32(mainVC.bingoData.maxNum))) + 1
                    mainVC.imageEvent.image = NSImage(named: shuffleNumber.description + ".png")
                    //displayCurrentNum(shuffleNumber) //窓透明化のためCurrentNumViewはいじれない
                } else {
                    mainVC.imageEvent.image = NSImage(named: mainVC.bingoData.eventName[mainVC.bingoData.eventKind] + ".jpg")
                }
            } else {
                //写真が4枚ある人用処理
                mainVC.imageEvent.image = NSImage(named: mainVC.bingoData.eventName[mainVC.bingoData.eventKind] + stopCount.description + ".jpg")
            }
            //音
            if stopCount < 4 {
                AnimationSubFunc.ringShuffleSound("pi")
            }
            
            if stopCount >= 4 {
                //写真拡大アニメーションへ
                timer.invalidate()
                preFrame = mainVC.imageEvent.frame
                stopCount = -10
                self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(BingoAnimation.animation4(_:)), userInfo: nil, repeats: true)
                //音
                AnimationSubFunc.ringShuffleSound("event")
            }
        }
    }
    
    //決定数字を表示する時の処理
    func actionAtNumDecided() -> Void {
        let nextNum = mainVC.bingoData.outputNextNum()
        mainVC.displayCurrentNum(nextNum)
        AnimationSubFunc.changeBlueToRed(mainVC.imageCurrentNum)
        
        preFrame = mainVC.imageCurrentNum.frame
        stopCount = -15
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: #selector(BingoAnimation.animation2(_:)), userInfo: nil, repeats: true)
        mainVC.renewPastNums(nextNum)
        
        //デン！
        AnimationSubFunc.ringShuffleSound("stop")
    }
    
    //イベント時窓切り抜き
    func eventWindow(event: Bool) -> Void {
        let bmap = NSBitmapImageRep(data: mainVC.imageCurrentNum.image!.TIFFRepresentation!)
        let bmap2 = NSBitmapImageRep(data: mainVC.imageBackground.image!.TIFFRepresentation!)
        
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
        
        mainVC.imageCurrentNum.image = NSImage(data: (bmap?.TIFFRepresentation)!)
        mainVC.imageBackground.image = NSImage(data: (bmap2?.TIFFRepresentation)!)
    }
    
    //currentImage回転(オープニングアニメーション)
    func animationOpening(timer: NSTimer) -> Void {
        mainVC.imageCurrentNum.rotateByAngle(10)
        mainVC.imageCurrentNum.setNeedsDisplay()
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
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(10-stopCount), preFrame: preFrame)
        } else if stopCount < 11 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 16 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(20-stopCount), preFrame: preFrame)
        } else if stopCount < 21 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount-10), preFrame: preFrame)
        } else if stopCount < 26 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(30-stopCount), preFrame: preFrame)
        } else if stopCount < 31 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount-20), preFrame: preFrame)
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
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(9.75), preFrame: preFrame)
        } else {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(10), preFrame: preFrame)
        }
        if stopCount > 30 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(10), preFrame: preFrame)
            timer.invalidate()
            //UI制御
            mainVC.subVC.buttonNext.enabled = true
            mainVC.subVC.buttonBingo.enabled = true
            mainVC.subVC.popUpNumsRemained.enabled = true
            mainVC.subVC.popUpEventKind.enabled = true
        }
    }
    
    //BINGO用(timer0.05)
    func animation3(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount <= 0 {
            return
        }
        if stopCount < 18 {
            mainVC.imageCurrentNum.hidden = false
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount), preFrame: preFrame)
        } else if stopCount < 25 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(34 - stopCount), preFrame: preFrame)
        } else if stopCount < 32 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount - 14), preFrame: preFrame)
        } else if stopCount < 39 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(48 - stopCount), preFrame: preFrame)
        } else if stopCount < 46 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(stopCount - 28), preFrame: preFrame)
        } else if stopCount < 53 {
            AnimationSubFunc.changeSize(mainVC.imageCurrentNum, rate: CGFloat(62 - stopCount), preFrame: preFrame)
        } else {
            timer.invalidate()
            //UI制御
            mainVC.subVC.buttonNext.enabled = true
            mainVC.subVC.buttonBingo.enabled = true
            mainVC.subVC.popUpEventKind.enabled = true
            mainVC.subVC.popUpNumsRemained.enabled = true
        }
    }
    
    //Eventイメージ拡大　favoriteボタンまでこのまま
    func animation4(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount >= 0 {
            if stopCount == 0 {
                //最前面へ
                var subviews = mainVC.view.subviews
                subviews.append(subviews[0])
                subviews.removeAtIndex(0)
                mainVC.view.subviews = subviews
            }
            if stopCount < 11 {
                let rate: CGFloat = CGFloat(stopCount)
                let width = preFrame.width + (mainVC.view.frame.width - preFrame.width) * rate / 10
                let heigt = preFrame.height + (mainVC.view.frame.height - preFrame.height) * rate / 10
                let x = preFrame.origin.x + (0 - preFrame.origin.x) * rate / 10
                let y = preFrame.origin.y + (0 - preFrame.origin.y) * rate / 10
                mainVC.imageEvent.setFrameSize(CGSize(width: width, height: heigt))
                mainVC.imageEvent.setFrameOrigin(NSPoint(x:  x, y: y))
                mainVC.imageEvent.setNeedsDisplay()
            } else {
                timer.invalidate()
                //UI制御
                mainVC.subVC.buttonFavorite.enabled = true
                mainVC.subVC.popUpNumsRemained.enabled = true
            }
        }
    }
    
    //Eventイメージ縮小　favorite処理
    func animation5(timer: NSTimer) -> Void {
        stopCount += 1
        if stopCount < 11 {
            let rate: CGFloat = CGFloat(stopCount)
            let width = mainVC.view.frame.width + (preFrame.width - mainVC.view.frame.width) * rate / 10
            let heigt = mainVC.view.frame.height + (preFrame.height - mainVC.view.frame.height) * rate / 10
            let x = 0 + (preFrame.origin.x - 0) * rate / 10
            let y = 0 + (preFrame.origin.y - 0) * rate / 10
            mainVC.imageEvent.setFrameSize(CGSize(width: width, height: heigt))
            mainVC.imageEvent.setFrameOrigin(NSPoint(x:  x, y: y))
            mainVC.imageEvent.setNeedsDisplay()
        } else if stopCount == 11 {
            //最背面へ
            var subviews = mainVC.view.subviews
            subviews.insert(subviews[5], atIndex: 0)
            subviews.removeLast()
            mainVC.view.subviews = subviews
        } else if stopCount < 21 {
        } else {
            timer.invalidate()
            //透明化解除して数字決定処理へ
            mainVC.bingoAnime.eventWindow(false)
            actionAtNumDecided()
        }
    }
}
