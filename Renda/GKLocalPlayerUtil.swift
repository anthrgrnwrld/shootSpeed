//
//  GKLocalPlayerUtil.swift
//  Renda
//
//  Created by Masaki Horimoto on 2015/08/11.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit
import GameKit

struct GKLocalPlayerUtil {
    static var localPlayer:GKLocalPlayer = GKLocalPlayer();
    
    static func login(target: UIViewController){
        self.localPlayer = GKLocalPlayer.localPlayer()
        self.localPlayer.authenticateHandler = {(viewController, error) -> Void in
            if ((viewController) != nil) {
                print("LoginCheck: Failed - LoginPageOpen")
                target.presentViewController(viewController!, animated: true, completion: nil);
            }else{
                print("LoginCheck: Success")
                if (error == nil){
                    print("LoginAuthentication: Success")
                }else{
                    print("LoginAuthentication: Failed")
                }
            }
        }
    }
}
