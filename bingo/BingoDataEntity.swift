//
//  BingoDataEntity.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/09/25.
//  Copyright © 2016年 Hiroshi Kadowaki and Daijiro Fukuda. All rights reserved.
//

import Cocoa

class BingoDataEntity: NSObject {
    
    /* === メンバ === */
    
    let maxNum = 75             //ビンゴの最大の数。(最小は1固定)
    var bingoNums:[Int] = []    //表示順に数字が入った配列
    var currentIndex = 0        //次表示するインデックス
    
    
    /* === メソッド === */
    
    //コンストラクタ 配列の値セット
    override init() {
        //tmpNumsに1からmaxNumまで順番に数字を格納
        var tmpNums:[Int] = []
        for i in 1...maxNum {
            tmpNums.append(i);
        }
        
        //tmpNumsからランダムに要素を取り出してbingoNumsに格納していく
        for i in 0...maxNum-1 {
            let randIndex = arc4random_uniform(UInt32(maxNum - i))
            bingoNums.append(tmpNums[Int(randIndex)])
            tmpNums.removeAtIndex(Int(randIndex))
        }
    }
    
    //次の数字(currentIndexの要素値)をInt出力, currentIndex更新
    func outputNextNum() -> Int {
        var result : Int
        
        if currentIndex < maxNum {
            result = bingoNums[currentIndex]
            currentIndex += 1
        } else {
            result = 1
        }
        
        return result
    }
    
    //履歴一覧String出力
    func outputPastNums() -> String {
        var result = ""
        
        if currentIndex > 0 {
            for i in 0...currentIndex-1 {
                result += bingoNums[i].description + " "
            }
        }
        result += "...(残り" + (maxNum - currentIndex).description + "個)"
        
        return result
    }
    
    //次の数字を任意のものに変更(履歴との重複は許さない, 要素をスワップ)
    //引数 favorite:次の数字にしたい数
    //返り値 true:変更成功, false:変更失敗(履歴との重複)
    func favoriteNum(favorite:Int) -> Bool {
        //重複確認
        var isDuplicated = false
        if currentIndex > 0 {
            for i in 0...currentIndex-1 {
                if favorite == bingoNums[i] {
                    isDuplicated = true
                    break
                }
            }
        }
        if isDuplicated {
            return false
        }
        //スワップ処理(currentIndexとfavoriteの値のインデックスとの要素値を入れ替える。favoriteの値のインデックスは総当たりで検索)
        if favorite != bingoNums[currentIndex] {//そもそもfavoriteが次の値なら処理の必要無し
            var isSearchSuccess = false
            /*↑favoriteの値のインデックスが見つかったかどうか。設計上、favoriteの値が1~maxNumの値であれば必ず見つかるはず。
            favoriteが無効な値だったとしても大丈夫なようにするため。*/
            for i in currentIndex+1...maxNum-1 {
                if favorite == bingoNums[i] {
                    let tmp = bingoNums[i]
                    bingoNums[i] = bingoNums[currentIndex]
                    bingoNums[currentIndex] = tmp
                    isSearchSuccess = true
                    break
                }
            }
            if isSearchSuccess == false {
                return false
            }
        }
        return true
    }
    
    //remainNums配列の全要素をString出力(試験用)
    func outputAllNum() -> String {
        var result = ""
        
        for i in bingoNums {
            result += i.description + " "
        }
        
        return result
    }
}
