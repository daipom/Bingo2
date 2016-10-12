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
    var eventKind = 0
    var eventName:[String] = ["default", "社長", "石田HB", "加藤B", "久鍋B", "高本B", "寺B", "FJB", "五十嵐顧問"]
    var subVC:SubVC!
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    
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
    
    //現状況の保存
    func saveData() -> Void {
        userDefaults.setObject(bingoNums, forKey: "NUMS")
        userDefaults.setInteger(currentIndex, forKey: "INDEX")
        userDefaults.synchronize()
    }
    
    //前回データの読み込み
    func loadData() -> Bool {
        if let nums = userDefaults.objectForKey("NUMS") as? [Int] {
            if let index:Int = userDefaults.integerForKey("INDEX") {
                bingoNums = nums
                currentIndex = index
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    //次の処理がイベントかどうか
    func isNextEvent() -> Bool {
        if eventKind == 0 {
            return false
        } else {
            return true
        }
    }
    
    //次の数字(currentIndexの要素値)をInt出力, currentIndex更新
    func outputNextNum() -> Int {
        var result : Int
        
        if currentIndex < maxNum {
            result = bingoNums[currentIndex]
            currentIndex += 1
            //コントロールのfavorite候補数字更新
            subVC.popUpNumsRemained.removeAllItems()
            subVC.popUpNumsRemained.addItemsWithTitles(outputRemainNums())
        } else {
            result = 0
        }
        
        return result
    }
    
    //残りの数字をString配列出力(popupItem用)
    func outputRemainNums() -> [String] {
        var result : [String] = []
        
        for num in 1...75 {
            var isRemained = true
            if currentIndex > 0 {
                for index in 0...currentIndex-1 {
                    if num == bingoNums[index] {
                        isRemained = false
                        break
                    }
                }
            }
            
            if isRemained {
                result.append(num.description)
            }
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
