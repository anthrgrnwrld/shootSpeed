//
//  GKScoreUtil.swift
//  Renda
//
//  Created by Masaki Horimoto on 2015/08/17.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit
import GameKit

struct GKScoreUtil {
    
    static func reportScores(_ value:Int, leaderboardid:String){
        print("\(#function) is called")
        
        let score:GKScore = GKScore();
        score.value = Int64(value);
        score.leaderboardIdentifier = leaderboardid;
        let scoreArr:[GKScore] = [score];
        
        GKScore.report(scoreArr, withCompletionHandler:{(error:Error?) -> Void in
            if( (error != nil)){
                print("reportScore NG");
            }else{
                print("reportScore OK");
            }
        });
        
    }
}
