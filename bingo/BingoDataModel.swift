//
//  BingoDataModel.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

class BingoDataModel: NSObject {
    
    /* === クラスメンバ === */
    
    //数字履歴の各行、各列の座標
    static let placeX:[Int] = [14, 145, 277, 408, 539, 671, 802, 933, 1065, 1196, 1327, 1459, 1590, 1721]
    static let placeY:[Int] = [14, 116, 217, 319, 421, 522, 624, 725, 827]
    //イベント用写真ファイルリスト
    static let eventName:[String] = ["default", "社長", "石田HB", "加藤B", "久鍋B", "高本B", "寺B", "FJB", "五十嵐顧問", "新納", "柴崎", "田中", "亀井"]
    static let onePhoteEventName:[String] = ["FJB", "五十嵐顧問", "新納", "柴崎", "田中", "亀井"]   //リストのうち写真が一枚の人たち
    
    
    /* === クラスメソッド === */
    
    //α値のみ変更する
    static func setAlpha(bmap: NSBitmapImageRep, x: Int, y: Int, alpha: CGFloat) -> Void {
        let red =  bmap.colorAtX(x, y: y)?.redComponent
        let green = bmap.colorAtX(x, y: y)?.greenComponent
        let blue = bmap.colorAtX(x, y: y)?.blueComponent
        bmap.setColor(NSColor.init(calibratedRed: red!, green: green!, blue: blue!, alpha: alpha), atX: x, y:y)
    }
    
    //数字が履歴表のどこの座標かを計算し、タプルで返す
    static func getPlace(num: Int) -> (startX: Int, startY: Int, endX: Int, endY: Int) {
        var line:Int = 0
        var col:Int = 0
        
        if num < 33 {
            line = (num - 1) / 8
            col = num - 1 - 8 * line
        } else if num < 36 {
            line = 4
            col = num - 28
        } else if num < 38 {
            line = 5
            col = num - 30
        } else if num < 39 {
            line = 6
            col = 7
        } else if num < 41 {
            line = 7
            col = num - 33
        } else if num < 44 {
            line = 8
            col = num - 36
        } else {
            line = (num - 44) / 8 + 9
            col = num - 44 - 8 * (line - 9)
        }
        
        return (placeX[line], placeY[col], placeX[line+1]-1, placeY[col+1]-1)
    }
}
