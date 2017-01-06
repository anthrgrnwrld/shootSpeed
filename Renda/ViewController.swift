//
//  ViewController.swift
//  Renda
//
//  Created by Masaki Horimoto on 2015/07/30.
//  Copyright (c) 2015年 Masaki Horimoto. All rights reserved.
//

import UIKit
import GameKit
import AudioToolbox
import Social

class ViewController: UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate,GADInterstitialDelegate {
    
    @IBOutlet var counterDigit: [UIImageView]!
    @IBOutlet var decimalPlace: [UIImageView]!
    @IBOutlet weak var positionBeeMostLeft: UIView!
    @IBOutlet weak var positionBeeMostRight: UIView!
    @IBOutlet weak var imageBee: UIImageView!
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var displayFrameView: UIView!
    @IBOutlet weak var buttanStart: UIButton!
    @IBOutlet weak var buttonTweet: UIButton!
    @IBOutlet weak var buttonGameCenter: UIButton!
    @IBOutlet weak var buttonFacebook: UIButton!
    
    let YOUR_BARNER_ID = "ca-app-pub-4555831884532149/4862920516"  // Enter Ad's ID here
    let YOUR_INTERSTITIAL_ID = "ca-app-pub-4555831884532149/5150752517"  // Enter Ad's ID here
    let TEST_DEVICE_ID = "61b0154xxxxxxxxxxxxxxxxxxxxxxxe0" // Enter Test ID here
    let AdMobTest:Bool = false
    let SimulatorTest:Bool = false
    var _interstitial: GADInterstitial?
    
    var countPushing = 0
    var countupTimer = 0
    var timer = Timer()
    let ud = UserDefaults.standard
    var timerState = false  //timerStateがfalseの時にはTimerをスタート。trueの時には無視する。
    var startState = false  //startStateがtrueの時にはゲーム開始できる
    var highScore = 0
    let udKey = "HIGHSCORE"
    let leaderboardid = "shootspeed.highscore"
    var kosuri:KosuriGestureRecognizer? = nil   //コスリクラスのインスタンス
    let buttonAImage :UIImage? = UIImage(named:"buttonA.png")
    let buttonBImage :UIImage? = UIImage(named:"buttonB.png")
    let buttonStartImage :UIImage? = UIImage(named:"buttonStart.png")
    let buttonAImageSelected :UIImage? = UIImage(named:"buttonA_selected.png")
    let buttonBImageSelected :UIImage? = UIImage(named:"buttonB_selected.png")
    let buttonStartImageSelected :UIImage? = UIImage(named:"buttonStart_selected.png")
    var capturedImage: UIImage?
    var count = 0
    var highScoreFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstDisplayLoad()
        
        let bannerView:GADBannerView = getAdBannerView()
        self.view.addSubview(bannerView)
        
        self.kosuri = KosuriGestureRecognizer(_targetViewA: self.buttonA, _targetViewB: self.buttonB, didPush: {
            self.pressButtonFunc()
        })
        
        capturedImage = GetImage() as UIImage     // キャプチャ画像を取得.

        _interstitial = createAndLoadInterstitial()


    }

    /**
    スクリーンキャプチャ用関数
    
    :returns: UIImage
    */
    func GetImage() -> UIImage {
        
        // キャプチャする範囲を取得.
        let rect = self.view.bounds
        
        // ビットマップ画像のcontextを作成.
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        // 対象のview内の描画をcontextに複写する.
        self.view.layer.render(in: context)
        
        // 現在のcontextのビットマップをUIImageとして取得.
        let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // contextを閉じる.
        UIGraphicsEndImageContext()
        
        return capturedImage
    }
    

    /**
    初期表示用関数
    */
    func firstDisplayLoad() {
        
        highScore = ud.integer(forKey: udKey)     //保存済みのハイスコアを取得
        print("highScore is \(highScore)")
        
        let tmpNum = counterDigit != nil ? counterDigit.count : 0
        
        //スコアを表示しているViewの枠線を描写
        displayView.layer.borderWidth = 1.0
        displayView.layer.borderColor = UIColor.gray.cgColor
        
        let highScoreAfterEdit = editCount(highScore, digitNum: tmpNum)
        updateCounter(highScoreAfterEdit)       //カウンタを初期表示にアップデート
        updateTimerLabel(0)                     //タイマーの初期表示をアップデート
        
        buttonDisplay()                         //ボタン画像表示
        adjustImageBee()                        //デバイス依存のimageBee調整処理
    }

    /**
    ボタン画像表示用関数
    */
    func buttonDisplay() {
        buttonA.setImage(buttonAImage!, for: UIControlState())
        buttonA.setImage(buttonAImageSelected!, for: .highlighted)
        buttonB.setImage(buttonBImage!, for: UIControlState())
        buttonB.setImage(buttonBImageSelected!, for: .highlighted)
        buttanStart.setImage(buttonStartImage!, for: UIControlState())
        buttanStart.setImage(buttonStartImageSelected!, for: .highlighted)
        buttonTweet.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        buttonGameCenter.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        buttonFacebook.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    
    /**
    AdMob表示用関数
    
    :returns: GADBannerView
    */
    fileprivate func getAdBannerView() -> GADBannerView {
        
        var bannerView: GADBannerView = GADBannerView()
        
        let myBoundSize = UIScreen.main.bounds.size  // Windowの表示領域を取得する。(広告の表示サイズのために使用する)
        if myBoundSize.width > 320 {bannerView = GADBannerView(adSize:kGADAdSizeFullBanner)}
        else {bannerView = GADBannerView(adSize:kGADAdSizeBanner)}
        
        bannerView.frame.origin = CGPoint(x: 0, y: 20)
        bannerView.frame.size = CGSize(width: self.view.frame.width, height: bannerView.frame.height)
        bannerView.adUnitID = "\(YOUR_BARNER_ID)"
        bannerView.delegate = self
        bannerView.rootViewController = self
        
        let request:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                request.testDevices = [kGADSimulatorID]
            } else {
                request.testDevices = [TEST_DEVICE_ID]
            }
        }
        
        bannerView.load(request)
        
        return bannerView
    }
    
    func adViewDidReceiveAd(_ adView: GADBannerView){
        print("adViewDidReceiveAd:\(adView)")
    }
    func adView(_ adView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError){
        print("error:\(error)")
    }
    func adViewWillPresentScreen(_ adView: GADBannerView){
        print("adViewWillPresentScreen")
    }
    func adViewWillDismissScreen(_ adView: GADBannerView){
        print("adViewWillDismissScreen")
    }
    func adViewDidDismissScreen(_ adView: GADBannerView){
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(_ adView: GADBannerView){
        print("adViewWillLeaveApplication")
    }
    
    override func viewDidLayoutSubviews() {
        
        adjustImageBee()

    }

    /**
    imageBeeのサイズ調整処理。320x480の解像度のデバイスのみ
    */
    func adjustImageBee() {
        let myBoundSize = UIScreen.main.bounds.size  // Windowの表示領域を取得する。(imageBeeの表示サイズのために使用する)
        if myBoundSize.height <= 480 {
            imageBee.bounds.size.height = 28    //320*480の表示時のみimageBeeの大きさを変更する
            imageBee.bounds.size.width = 28
        }
    }

    
    /**
    Startボタンを押した時に実行する関数 その1
    */
    @IBAction func buttonStart(_ sender: AnyObject) {
        
        if startState != false {    //starStateがtrueの時には処理を終了
            return
        }
        
        highScoreFlag = false
        
        //Viewの点滅を終了する。
        finishBlinkAnimationWithView(imageBee)
        for (_, view) in self.counterDigit.enumerated() {
            finishBlinkAnimationWithView(view)
        }
        
        startState = true           //startStateがtrueにし、Gameが開始できる状態にする
        countPushing = 0
        countupTimer = 0
        updateCounter([0,0,0,0])    //カウンタを初期表示にアップデート
        updateTimerLabel(10)        //タイマーの初期表示をアップデート
        imageBee.center = positionBeeMostRight.center   //imageBeeの表示位置を初期値に戻す
        
    }
    
    /**
    Startボタンを押した時に実行する関数 その2 (音声再生用)
    */
    @IBAction func buttonStart2(_ sender: AnyObject) {
        
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")
        
    }

    /**
    Aボタンを押した時に実行する関数
    */
    @IBAction func pressButtonA(_ sender: AnyObject) {
        
        pressButtonFunc()
        
    }

    /**
    Bボタンを押した時に実行する関数
    */
    @IBAction func pressButtonB(_ sender: AnyObject) {

        pressButtonFunc()
        
    }

    
    /**
    Aボタン及びBボタンを押した時に実行する関数
    */
    func pressButtonFunc() {
        
        //println("\(__FUNCTION__) is called")
        
        //timerStateがfalseの時にはTimerをスタート。trueの時には無視する。
        if timerState == false && startState {
            timerState = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ViewController.updateTimer), userInfo: nil, repeats: true)
        }
        
        if timerState && startState {
            
            countPushing += 1  //countPushingをインクリメント
 
            let tmpNum = counterDigit != nil ? counterDigit.count : 0
            
            let countAfterEdit = editCount(countPushing, digitNum: tmpNum)  //カウントを表示用にEdit
            updateCounter(countAfterEdit)   //カウンタをアップデートする
            moveImageBeeWithCountPushing(countPushing)  //imageBeeの表示位置をアップデートする
            
        }
        
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")
        
    }

    /**
    バイブレーション無しでシステムサウンドを再生する。
    http://iphonedevwiki.net/index.php/AudioServices 参照
    
    :param: soundName:再生したいシステムサウンドのファイル名
    */
    func AudioServicesPlaySystemSoundWithoutVibration(_ soundName :String) {
        
        var soundIdRing:SystemSoundID = 0
        let soundUrl = URL(fileURLWithPath: "/System/Library/Audio/UISounds/\(soundName)")
        AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdRing)
        AudioServicesPlaySystemSound(soundIdRing)
        
    }
        
    /**
    表示用にカウント数を10進数の桁毎に数値を分割する。表示桁数を超えた場合にはゼロに戻す。
    digiNum >= count となるようにして使用のこと。
    
    :param: count:カウント数
    :param: digitNum:変換する桁数
    :returns: digitArray:変換結果を入れる配列
    */
    func editCount(_ count :Int, digitNum :Int) -> [Int] {
        var count = count
        
        var digitArray = [Int]()
        
        for index in 0 ... (digitNum) {
            let tmpDec = pow(10.0, Double(digitNum - index))
            if index != 0 {digitArray.append(count / Int(tmpDec))}
            count = count % Int(tmpDec)
        }
        
        return digitArray
    }
    
    /**
    カウンタの表示LabelをUpdateする。
    countArrayの要素数 = counterDigitの要素数となるよう使用のこと。
    
    :param: countArray:配列に編集済みのカウント配列*要editCount
    */
    func updateCounter(_ countArray :[Int]) {
        
        if counterDigit != nil && countArray.count == counterDigit.count {
            
            for index in 0 ... (countArray.count - 1) {
                counterDigit[index].tag = countArray[index]
                counterDigit[index].image = UIImage(named: "\(counterDigit[index].tag).png")
            }
            
        } else if counterDigit != nil && countArray.count != counterDigit.count {
            
            for index in 0 ... (countArray.count - 1) {
                counterDigit[index].tag = 0x0e
                counterDigit[index].image = UIImage(named: "\(counterDigit[index].tag).png")
            }
            print("Error")
            
        } else {    //counterDigit == nil
            
            //Do nothing
            
        }
        
        undisplayZero(countArray)
        
    }

    /**
    カウンタの表示Labelで不要な0を非表示にする。
    countArrayの要素数 = counterDigitの要素数となるよう使用のこと。
    
    :param: countArray:配列に編集済みのカウント配列*要editCount
    */
    func undisplayZero(_ countArray :[Int]) {
        
        for index in 0 ... (countArray.count - 1) {counterDigit[index].alpha = 1.0}
        
        if countArray[0] == 0 {
            counterDigit[0].alpha = 0
            
            if countArray[1] == 0 {
                counterDigit[1].alpha = 0
                
                if countArray[2] == 0 {
                    counterDigit[2].alpha = 0
                }
                
            }
            
        }
        
    }
    
    /**
    タイマー関数。1秒毎に呼び出される。
    */
    func updateTimer() {
        //println("\(__FUNCTION__) is called")
        
        countupTimer += 1                                      //countupTimerをインクリメント
        let countdownTimer = editTimerCount(countupTimer)   //カウントアップ表記をカウントダウン表記へ変換
        updateTimerLabel(countdownTimer)                    //タイマー表示ラベルをアップデート
        
        if countdownTimer <= 0 {timeupFunc()}               //ゲーム開始より10秒経過後、ゲーム完了処理を実行
        
        print("\(#function) is called! \(countupTimer)")
    }
    
    /**
    ゲーム完了時に実行する関数。
    */
    func timeupFunc() {

        highScoreFlag = countPushing > highScore ? true : false
        highScore = countPushing > highScore ? countPushing : highScore
        timerState = false
        startState = false
        timer.invalidate()
        print("highScore is \(highScore)")
        ud.set(highScore, forKey: udKey)     //ハイスコアをNSUserDefaultsのインスタンスに保存
        ud.synchronize()                            //保存する情報の反映
        GKScoreUtil.reportScores(highScore, leaderboardid: leaderboardid)   //GameCenter Score Transration
        
        //ハイスコア更新の場合にはimageBeeとカウンタ表示を点滅させる & サウンドを再生する & スクリーンキャプチャ
        if highScoreFlag {
            capturedImage = GetImage() as UIImage     // キャプチャ画像を取得.
            AudioServicesPlaySystemSoundWithoutVibration("alarm.caf")
            blinkAnimationWithView(imageBee)
            for (_, view) in self.counterDigit.enumerated() {
                blinkAnimationWithView(view)
            }
        }
        
        count += 1
        
        if count > 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.presentInterstitial()
            }
            
        }
        

    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial!) {
        
        //ハイスコア更新の場合にはimageBeeとカウンタ表示を点滅させる
        if highScoreFlag {
            finishBlinkAnimationWithView(imageBee)
            firstDisplayLoad()
            blinkAnimationWithView(imageBee)
            for (_, view) in self.counterDigit.enumerated() {
                blinkAnimationWithView(view)
            }
        }
    }
    
    /**
    指定されたViewを1秒間隔で点滅させる
    
    :param: view:点滅させるView
    */
    func blinkAnimationWithView(_ view :UIView) {
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.repeat, animations: { () -> Void in
            view.alpha = 0
            }, completion: nil)
    }
    
    /**
    指定されたViewの点滅アニメーションを終了する
    
    :param: view:点滅を終了するView
    */
    func finishBlinkAnimationWithView(_ view :UIView) {
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.animate(withDuration: 0.001, animations: {
            view.alpha = 1.0
        })
//        //こっちの方法でもOK
//        view.layer.removeAllAnimations()
//        view.alpha = 1.0
    }
    
    /**
    カウントアップタイマーを1カウントダウン表記(Start 10)に変更する。
    timerCount > 10 の場合には0をReturnする
    
    :param: timerCount:カウントアップタイマ値
    :returns: digitArray:カウントダウンタイマ値(Start 10)
    */
    func editTimerCount(_ timerCount: Int) -> Int {
        
        var timerCountAfterEdit: Int?
        
        if 10 >= timerCount {timerCountAfterEdit = 10 - timerCount}
        else {timerCountAfterEdit = 0}
        
        return timerCountAfterEdit!
        
    }
    
    /**
    タイマーの表示LabelをUpdateする。
    
    :param: countArray:配列に編集済みのカウント配列*要editCount
    */
    func updateTimerLabel(_ timerCount: Int) {
 
        if decimalPlace != nil {

            decimalPlace[0].tag = timerCount/10
            decimalPlace[1].tag = timerCount%10
            
            decimalPlace[0].image = UIImage(named: "\(decimalPlace[0].tag).png")
            decimalPlace[1].image = UIImage(named: "\(decimalPlace[1].tag).png")

        }
        
        decimalPlace[0].alpha = 1.0
        if timerCount < 10 {decimalPlace[0].alpha = 0}
        
    }

    /**
    GameCenterボタンを押した時に実行する関数
    */
    @IBAction func pressGameCenter(_ sender: AnyObject) {
        
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")
        
        showLeaderboardScore()

    }
    
    /**
    GKScoreにてスコアが送信されたデータスコアをLeaderboardで確認する
    */
    func showLeaderboardScore() {
        
        if timerState {    //timerStateがtrueの時(=ゲーム実行中)は処理を終了
            return
        }
        
        let localPlayer = GKLocalPlayer()
        localPlayer.loadDefaultLeaderboardIdentifier { (leaderboardIdentifier : String?, error : Error?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                
                let iOSVersion: NSString! = UIDevice.current.systemVersion as NSString
                print("iOSVersion is \(iOSVersion)")
                
                //Verによってアラート動作を変える
//                if iOSVersion.floatValue < 8.0 { self.showAlertIOS7() }
//                else { self.showAlertIOS8() }
                
                self.showAlert()
                
            } else {
                let gameCenterController:GKGameCenterViewController = GKGameCenterViewController()
                gameCenterController.gameCenterDelegate = self  //このViewControllerにはGameCenterControllerDelegateが実装されている必要があります
                gameCenterController.viewState = GKGameCenterViewControllerState.leaderboards
                gameCenterController.leaderboardIdentifier = self.leaderboardid //該当するLeaderboardのIDを指定します
                self.present(gameCenterController, animated: true, completion: nil);
            }
        }

        
    }
    
    let alertTitle:String = NSLocalizedString("alertTitle", comment: "アラートのタイトル")
    let alertMessage:String = NSLocalizedString("alertMessage", comment: "アラートのメッセージ")
    let actionTitle = "OK"
    
    func showAlert() {
        
        if #available(iOS 8.0, *) {
            // Style Alert
            let alert: UIAlertController = UIAlertController(title:alertTitle,
                message: alertMessage,
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            // Default 複数指定可
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    print("OK")
            })
            
            // AddAction 記述順に反映される
            alert.addAction(defaultAction)
            
            // Display
            present(alert, animated: true, completion: nil)
        } else {
            
            // Fallback on earlier versions
            let alert = UIAlertView()
            alert.title = alertTitle
            alert.message = alertMessage
            alert.addButton(withTitle: actionTitle)
            alert.show()
            
        }
        
    }
        
    
    @IBAction func pressHowToPlay(_ sender: AnyObject) {
        
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")

        //Verによってアラート動作を変える
//        let iOSVersion: NSString! = UIDevice.currentDevice().systemVersion as NSString
//        print("iOSVersion is \(iOSVersion)")
//        if iOSVersion.floatValue < 8.0 { self.showHowToPlayIOS8() }
//        else { self.showHowToPlayIOS7() }
        
        self.showHowToPlay()
        
    }
    
    let howToPlayTitle:String = NSLocalizedString("howToPlayTitle", comment: "How to playのタイトル")
    let howToPlayMessage:String = NSLocalizedString("howToPlayMessage", comment: "How to playのメッセージ")
    let howToPlayActionTitle = "OK"
    
    func showHowToPlay() {
        
        if timerState {    //timerStateがtrueの時(=ゲーム実行中)は処理を終了
            return
        }
        
        // Style Alert
        if #available(iOS 8.0, *) {
            let alert: UIAlertController = UIAlertController(title:howToPlayTitle,
                message: howToPlayMessage,
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            // Default 複数指定可
            let defaultAction: UIAlertAction = UIAlertAction(title: "OK",
                style: UIAlertActionStyle.default,
                handler:{
                    (action:UIAlertAction!) -> Void in
                    print("OK")
            })
            
            // AddAction 記述順に反映される
            alert.addAction(defaultAction)
            
            // Display
            present(alert, animated: true, completion: nil)
            
        } else {
            // Fallback on earlier versions
            let alert = UIAlertView()
            alert.title = howToPlayTitle
            alert.message = howToPlayMessage
            alert.addButton(withTitle: howToPlayActionTitle)
            alert.show()
        }

        
    }
    
    /**
    Leaderboardを"DONE"押下後にCloseする
    */
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        print("\(#function) is called")
        //code to dismiss your gameCenterViewController
        gameCenterViewController.dismiss(animated: true, completion: nil);
    }
    
    /**
    imageBeeの表示位置を変更する。
    
    :param: countPushing:Pushカウント数
    */
    func moveImageBeeWithCountPushing(_ countPushing: Int) {
        print("countPushing is \(countPushing)")
        
        let deltaXperOnePushing = (positionBeeMostRight.center.x - positionBeeMostLeft.center.x)/160    //1Push当たりのx移動量
        if (countPushing - 1) % 160 == 0 {imageBee.center.x = positionBeeMostRight.center.x}            //160回毎にpositionBeeMostLeftに位置を戻す *16連射目標のため
        imageBee.center.x -= deltaXperOnePushing                                                        //imageBeeの表示位置を移動する
        
    }

    @IBAction func pressTweet(_ sender: AnyObject) {
        
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")
        
        if timerState {    //timerStateがtrueの時(=ゲーム実行中)は処理を終了
            return
        }
        
        let twitterPostView:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)!
        let tweetDescription0:String = NSLocalizedString("shareDescription0", comment: "ツイート内容0")
        let tweetDescription1:String = NSLocalizedString("shareDescription1", comment: "ツイート内容1")
        let tweetDescription2:String = NSLocalizedString("shareDescription2", comment: "ツイート内容2")
        let tweetDescription3:String = NSLocalizedString("shareDescription3", comment: "ツイート内容3")
        let tweetDescription4:String = NSLocalizedString("shareDescription4", comment: "ツイート内容4")
        let tweetURL:URL = URL(string: "https://itunes.apple.com/us/app/get-high-score!-how-many-times/id1029309778?l=ja&ls=1&mt=8")!

        //ハイスコアが160回超えた時とそれ以下で表示メッセージを変える。
        if highScore > 160 {
            twitterPostView.setInitialText("\(tweetDescription0)\(highScore)\(tweetDescription3)\(abs(160 - highScore))\(tweetDescription4)")
        } else {
            twitterPostView.setInitialText("\(tweetDescription0)\(highScore)\(tweetDescription1)\(abs(160 - highScore))\(tweetDescription2)")
            
        }

        twitterPostView.add(tweetURL)
        twitterPostView.add(capturedImage)

        self.present(twitterPostView, animated: true, completion: nil)
        
    }

    @IBAction func pressFacebook(_ sender: AnyObject) {
        AudioServicesPlaySystemSoundWithoutVibration("Tink.caf")
        
        if timerState {    //timerStateがtrueの時(=ゲーム実行中)は処理を終了
            return
        }

        let facebookPostView:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)!
        let facebookDescription0:String = NSLocalizedString("shareDescription0", comment: "ツイート内容0")
        let facebookDescription1:String = NSLocalizedString("shareDescription1", comment: "ツイート内容1")
        let facebookDescription2:String = NSLocalizedString("shareDescription2", comment: "ツイート内容2")
        let facebookDescription3:String = NSLocalizedString("shareDescription3", comment: "ツイート内容3")
        let facebookDescription4:String = NSLocalizedString("shareDescription4", comment: "ツイート内容4")
        let facebookURL:URL = URL(string: "https://itunes.apple.com/us/app/shootspeed-get-high-score!/id1029309778?l=ja&ls=1&mt=8")!
        
        //ハイスコアが160回超えた時とそれ以下で表示メッセージを変える。
        if highScore > 160 {
            facebookPostView.setInitialText("\(facebookDescription0)\(highScore)\(facebookDescription3)\(abs(160 - highScore))\(facebookDescription4)")
        } else {
            facebookPostView.setInitialText("\(facebookDescription0)\(highScore)\(facebookDescription1)\(abs(160 - highScore))\(facebookDescription2)")
            
        }
        
        facebookPostView.add(facebookURL)
        facebookPostView.add(capturedImage)
        
        self.present(facebookPostView, animated: true, completion: nil)
        
    }
    
    fileprivate func createAndLoadInterstitial()->GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: YOUR_INTERSTITIAL_ID)
        interstitial?.delegate = self
        let request:GADRequest = GADRequest()
        
        if AdMobTest {
            if SimulatorTest {
                request.testDevices = [kGADSimulatorID]
            } else {
                request.testDevices = [TEST_DEVICE_ID]
            }
        }
        
        interstitial?.load(request)
        
        return interstitial!
    }
    
    fileprivate func presentInterstitial() {
        
        guard let interstitial = _interstitial else {
            print ("_interstitial is nil.")
            return
        }
        
        interstitial.present(fromRootViewController: self)
        
    }

}

