//
//  SubVC.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/10/07.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

protocol ActionDelegate {//ビンゴ進行動作をメインのVCに委譲するためのプロトコル
    func takeAction() -> Void
    func favoriteNum(favorite: Int) -> Void
}

/* メインVC制御ウィンドウ */
class SubVC: NSViewController {
    
    /*　=== メンバ === */
    
    var delegate: ActionDelegate?   //ボタン動作を委譲するデリゲート先( = ViewController)
    
    
    /* === メソッド === */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    
    /* === インタフェースビルダー === */
    @IBOutlet weak var textFieldFavorite: NSTextField!
    
    
    //ボタン:ビンゴ進行
    @IBAction func buttonTapped(sender: AnyObject) {
        self.delegate?.takeAction()
    }
    
    @IBAction func favoriteTapped(sender: AnyObject) {
        self.delegate?.favoriteNum(Int(textFieldFavorite.stringValue)!)
    }
    
}
