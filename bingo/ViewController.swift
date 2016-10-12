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
    var bingoAnime:BingoAnimation! = nil
    var subVC : SubVC!  //コントロールウィンドウの制御オブジェクトへアクセスするため
    
    
    /* === メソッド === */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* Do any additional setup after loading the view. */
        //bingoAnimeイニシャライズ
        bingoAnime = BingoAnimation(mainVC: self)
        bingoAnime.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: bingoAnime, selector: #selector(BingoAnimation.shuffleRoulette(_:)), userInfo: nil, repeats: true)   //タイマーがnilのままではエラーが出てしまうのでとりあえず
        bingoAnime.timer.invalidate()

        
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
        bingoAnime.openingTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: bingoAnime, selector: #selector(BingoAnimation.animationOpening(_:)), userInfo: nil, repeats: true)
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
        if bingoAnime.openingTimer.valid {
            bingoAnime.openingTimer.invalidate()
            imageCurrentNum.rotateByAngle(-bingoAnime.currentAngle)
            subVC.buttonBingo.enabled = true
            subVC.buttonLoad.enabled = false
        }
        //メイン処理
        if bingoAnime.timer.valid {
            subVC.buttonNext.enabled = false
            bingoData.eventKind = kind
            bingoAnime.timer.invalidate()
            
            if bingoData.isNextEvent() {//イベント時前処理
                imageEvent.image = imageCurrentNum.image  //一瞬窓が透明になる際のカモフラージュ
                bingoAnime.eventWindow(true)   //処理に時間がかかるためtimerがスタートする前に処理
            }
            
            bingoAnime.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: bingoAnime, selector: #selector(BingoAnimation.stopRoulette(_:)), userInfo: nil, repeats: true)
            bingoAnime.stopCount = 0
        } else {
            bingoAnime.timer = NSTimer.scheduledTimerWithTimeInterval(0.09, target: bingoAnime, selector: #selector(BingoAnimation.shuffleRoulette(_:)), userInfo: nil, repeats: true)
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
                bingoAnime.stopCount = 0
                bingoAnime.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: bingoAnime, selector: #selector(BingoAnimation.animation5(_:)), userInfo: nil, repeats: true)
                //UI制御
                subVC.popUpNumsRemained.enabled = false
            }
        }
    }
    //ビンゴ表示!!
    func bingo() -> Void {
        if !bingoAnime.timer.valid {
            imageCurrentNum.hidden = true
            imageCurrentNum.image = NSImage(named: "BINGO.png")
            bingoAnime.preFrame = imageCurrentNum.frame
            bingoAnime.stopCount = 0
            bingoAnime.timer = NSTimer.scheduledTimerWithTimeInterval(0.05, target: bingoAnime, selector: #selector(BingoAnimation.animation3(_:)), userInfo: nil, repeats: true)
            //音
            AnimationSubFunc.ringShuffleSound("bingo")
            //UI制御
            subVC.buttonNext.enabled = false
            subVC.buttonBingo.enabled = false
            subVC.popUpEventKind.enabled = false
            subVC.popUpNumsRemained.enabled = false
        }
    }
    //前回データロード(一回もnextを押していない初期状態でのみ可能)
    func loadPreData() -> Void {
        if bingoData.loadData() {
            for index in 0...bingoData.currentIndex-1 {
                renewPastNums(bingoData.bingoNums[index])
            }
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

