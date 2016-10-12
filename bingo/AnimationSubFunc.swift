//
//  AnimationSubFunc.swift
//  bingo
//
//  Created by Daijiro Fukuda on 2016/10/12.
//  Copyright © 2016年Hiroshi Kadowaki and  Daijiro Fukuda. All rights reserved.
//

import Cocoa
import AudioToolbox

class AnimationSubFunc: NSObject {
    
    //音出力
    static func ringShuffleSound(soundFileName: String) {
        var soundIDRing:SystemSoundID = 1
        let soundUrl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(soundFileName, ofType: "mp3")!)
        AudioServicesCreateSystemSoundID(soundUrl, &soundIDRing)    //参照した音声ファイルからIDを作成
        AudioServicesPlaySystemSound(soundIDRing)   //作成したIDから音声を再生する
    }

    //NSViewサイズ変更
    static func changeSize(imageView: NSImageView, rate: CGFloat, preFrame: NSRect) -> Void {
        let width = preFrame.width * rate / 10
        let heigt = preFrame.height * rate / 10
        let x = preFrame.origin.x + (preFrame.width - width) / 2
        let y = preFrame.origin.y + (preFrame.height - heigt) / 2
        imageView.setFrameSize(CGSize(width: width, height: heigt))
        imageView.setFrameOrigin(NSPoint(x:  x, y: y))
        imageView.setNeedsDisplay()
    }
    
    static func changeSizeToSpecifiedSize(imageView: NSImageView, rate: CGFloat, preFrame: NSRect, goalFrame: NSRect) -> Void {
        let width = preFrame.width + (goalFrame.width - preFrame.width) * rate / 10
        let heigt = preFrame.height + (goalFrame.height - preFrame.height) * rate / 10
        let x = preFrame.origin.x + (preFrame.width - width) / 2
        let y = preFrame.origin.y + (preFrame.height - heigt) / 2
        imageView.setFrameSize(CGSize(width: width, height: heigt))
        imageView.setFrameOrigin(NSPoint(x:  x, y: y))
        imageView.setNeedsDisplay()
    }
    
    //青色を赤色に変換
    static func changeBlueToRed(imageView: NSImageView) -> Void {
        let bmap = NSBitmapImageRep(data: imageView.image!.TIFFRepresentation!)
        for x in 0...598 {
            for y in 0...581 {
                //青い部分を赤色に
                let color = bmap!.colorAtX(x, y: y)
                if color?.blueComponent > 0.2 && color?.redComponent < 0.5 {
                    bmap!.setColor(NSColor.init(calibratedRed: 1.0, green: 0, blue: 0, alpha: 1.0), atX: x, y: y)
                }
            }
        }
        imageView.image = NSImage(data: (bmap?.TIFFRepresentation)!)
    }
}
