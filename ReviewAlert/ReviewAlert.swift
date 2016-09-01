//
//  ReviewAlert.swift
//  ReviewAlert
//
//  Created by Kentarou on 2016/09/01.
//  Copyright © 2016年 Kentarou. All rights reserved.
//

import Foundation
import UIKit


class ReviewAlert {
    
    // UserDefault Key
    let appVersionKey       = "AppVersion"
    let reviewStatusKey     = "ReviewStatusKey"
    let currenAppVersionKey = "CFBundleShortVersionString"
    
    // Review Show Count
    let firstAlertCount = 2
    let afterAlertCount = 15
    
    /// Singleton生成
    static let sharedInstance: ReviewAlert = {
        let instance = ReviewAlert()
        // 初期値設定
        if let version = instance.userDefault.stringForKey(instance.appVersionKey) {
            if !instance.compareAppVersion(version) {
                instance.resetStatus()
                instance.setAppVersion()
            }
        } else {
            instance.setAppVersion()
        }
        instance.reviewStatus = ReviewStatus.readReviewStatus()
        
        return instance
    }()
    
    let userDefault = NSUserDefaults.standardUserDefaults()
    var reviewStatus: ReviewStatus = .none(count: 0) {
        didSet {
            reviewStatus.saveReviewStatus()
        }
    }

    enum ReviewStatus {
        // Reviewの状態
        case none(count: Int)
        case after(count: Int)
        case never
        
        // Review Statusを保存
        func saveReviewStatus() {
            var value: [String: AnyObject]!
            switch self {
            case .none(let count) : value = ["none" : count]
            case .after(let count): value = ["after": count]
            case .never           : value = ["never": ""]
            }
            
            NSUserDefaults.standardUserDefaults().setObject(value, forKey: "ReviewStatusKey")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Review Statusを呼び出し
        static func readReviewStatus() -> ReviewStatus {
            if let status = NSUserDefaults.standardUserDefaults().objectForKey("ReviewStatusKey") as? [String: AnyObject] {
                let key = status.keys.first!
                let value = status[key]
                switch key {
                    case "none" : return .none(count: value as! Int)
                    case "after": return .after(count: value as! Int)
                    default     : return .never
                }
                
            } else {
                // 初期値
                return .none(count: 0)
            }
        }
    }
    
    /// 現在のアプリバージョンを取得
    var currentAppVersion: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(currenAppVersionKey) as! String
    }

    
    /// ReviewStatusをリセットする
    func resetStatus()  {
        reviewStatus = .none(count: 0)
    }
    
    /// 現在のVersionを保存する
    func setAppVersion()  {
        userDefault.setObject(currentAppVersion, forKey: appVersionKey)
        userDefault.synchronize()
    }
    
    /// UserDefaultのアプリVersionを比較する
    func compareAppVersion(version: String) -> Bool {
        return version == currentAppVersion ? true : false
    }
    
    /// レビューアラートを表示するかチェックする
    func checkReviewAlert(vc: UIViewController) {
        
        switch reviewStatus {
        case .none(var count) :
            count += 1
            reviewStatus = .none(count: count)
            if count >= firstAlertCount {
                showReviewAlert(vc)
            }
        case .after(var count):
            count += 1
            reviewStatus = .after(count: Int(count))
            if count >= afterAlertCount {
                showReviewAlert(vc)
            }
        case .never:
            break
        }
    }
    
    /// レビューアラートを表示する
    func showReviewAlert(vc: UIViewController) {
        
        let alert = UIAlertController(title: "ReviewAlert", message: "message", preferredStyle: .Alert)
        
        let action1 = UIAlertAction(title: "レビューする", style: .Default, handler: { action in
            self.reviewStatus = .never
            // レビュー画面へ
        })
        let action2 = UIAlertAction(title: "後で", style: .Default, handler: { action in
            self.reviewStatus = .after(count: 0)
        })
        let action3 = UIAlertAction(title: "レビューしない", style: .Default, handler: { action in
            self.reviewStatus = .never
        })
        
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        vc.presentViewController(alert, animated: true, completion: nil)
    }
}







