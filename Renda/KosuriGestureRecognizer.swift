//
//  KosuriGestureRecognizer.swift
//  Renda
//
//  Created by Masaki Horimoto on 2015/09/02.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit


/**
2つのViewにおいて、PanにてView範囲に入った時に、closureで指定された動作を行う。
使用例:コスリ機能

- parameter _targetViewA:対象となるView(1つ目):
- parameter _targetViewB:対象となるView(2つ目):
- parameter 対象となるView範囲に入った時に実行する動作:
*/
class KosuriGestureRecognizer : NSObject {
    let pan = UIPanGestureRecognizer()
//    let tap = UITapGestureRecognizer()  //複数のUIGestureRecognizerを持ったクラスのテスト
    
    var targetViewA:UIButton? = nil   //targetViewAとtargetViewBは同じsuperviewを持っていること
    var targetViewB:UIButton? = nil   //targetViewAとtargetViewBは同じsuperviewを持っていること
    var didPush:(()->Void)? = nil
    
    var inFlagA = false
    var inFlagB = false
    
    //UIButtonクラスからUIImageを取得出来なかったので（何故？？）以下にて対応
    let buttonAImage = UIImage(named:"buttonA.png")
    let buttonAImageSelected = UIImage(named:"buttonA_selected.png")
    let buttonBImage = UIImage(named:"buttonB.png")
    let buttonBImageSelected = UIImage(named:"buttonB_selected.png")
    
    init(_targetViewA:UIButton, _targetViewB:UIButton, didPush:@escaping ()->Void) {
        super.init()
        
        self.targetViewA = _targetViewA
        self.targetViewB = _targetViewB
        self.didPush = didPush
        
        pan.addTarget(self, action: #selector(KosuriGestureRecognizer.didPan(_:)))
        _targetViewA.superview?.superview?.addGestureRecognizer(self.pan)

//        //複数のUIGestureRecognizerを持ったクラスのテスト
//        tap.addTarget(self, action: Selector("didTap:"))
//        _targetViewA.superview?.superview?.addGestureRecognizer(self.tap)

        
    }
    
    func didPan(_ sender:AnyObject) {
        if let pan = sender as? UIPanGestureRecognizer,
            let targetViewA = self.targetViewA,
            let targetViewB = self.targetViewB,
            let outView = targetViewA.superview,
            let didPush = self.didPush
        {
            let p = pan.location(in: outView) //outViewはViewControllerでいうところのself.view
            if !inFlagA && targetViewA.frame.contains(p) {
                inFlagA = true
                didPush()
                targetViewA.setImage(buttonAImageSelected!, for: UIControlState())
            } else if inFlagA && !targetViewA.frame.contains(p) {
                inFlagA = false
                targetViewA.setImage(buttonAImage!, for: UIControlState())
            } else if !inFlagB && targetViewB.frame.contains(p) {
                inFlagB = true
                didPush()
                targetViewB.setImage(buttonBImageSelected!, for: UIControlState())
            } else if inFlagB && !targetViewB.frame.contains(p) {
                inFlagB = false
                targetViewB.setImage(buttonBImage!, for: UIControlState())
            } else if sender.state == .ended {
                targetViewA.setImage(buttonAImage!, for: UIControlState())
                targetViewB.setImage(buttonBImage!, for: UIControlState())
            }
        }
    }

//    //複数のUIGestureRecognizerを持ったクラスのテスト
//    func didTap(sender: AnyObject){
//        if sender.state == .Ended {
//            println("\(__FUNCTION__)")
//            targetViewA!.setImage(buttonAImage!, forState: .Normal)
//            targetViewB!.setImage(buttonBImage!, forState: .Normal)
//        }
//    }
    
}

