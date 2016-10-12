//
//  SubVC.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/10/07.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

protocol ActionDelegate {//ビンゴ進行動作をメインのVCに委譲するためのプロトコル
    func takeAction(kind: Int) -> Void
    func favoriteNum(favorite: Int) -> Void
    func bingo() -> Void
    func loadPreData() -> Void
}

/* メインVC制御ウィンドウ */
class SubVC: NSViewController {
    
    /*　=== メンバ === */
    
    var delegate: ActionDelegate?   //ボタン動作を委譲するデリゲート先( = ViewController)
    
    
    /* === メソッド === */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        popUpEventKind.removeAllItems()
        popUpEventKind.addItemsWithTitles(["default", "社長", "石田HB", "加藤", "久鍋", "高本", "寺B", "石田FJB", "五十嵐顧問"])
        popUpNumsRemained.removeAllItems()
        for num in 1...75 {
            popUpNumsRemained.addItemWithTitle(num.description)
        }
        buttonFavorite.enabled = false
        buttonBingo.enabled = false
    }
    
    
    /* === インタフェースビルダー === */
    @IBOutlet weak var popUpEventKind: NSPopUpButton!
    
    @IBOutlet weak var popUpNumsRemained: NSPopUpButton!
    
    @IBOutlet weak var buttonNext: NSButton!
    
    @IBOutlet weak var buttonFavorite: NSButton!
    
    @IBOutlet weak var buttonBingo: NSButton!
    
    @IBOutlet weak var buttonLoad: NSButton!
    
    //ボタン:ビンゴ進行
    @IBAction func buttonTapped(sender: AnyObject) {
        self.delegate?.takeAction(popUpEventKind.indexOfSelectedItem)
    }
    
    @IBAction func favoriteTapped(sender: AnyObject) {
        self.delegate?.favoriteNum(Int(popUpNumsRemained.titleOfSelectedItem!)!)
    }
    
    @IBAction func bingoTapped(sender: AnyObject) {
        self.delegate?.bingo()
    }
    
    @IBAction func loadTapped(sender: AnyObject) {
        self.delegate?.loadPreData()
    }
}
