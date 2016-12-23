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
    let firstAlertCount = 7
    let afterAlertCount = 10
    
    /// Singleton生成
    static let sharedInstance: ReviewAlert = {
        let instance = ReviewAlert()
        // 初期値設定
        if let version = instance.userDefault.string(forKey: instance.appVersionKey) {
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
    
    let userDefault = UserDefaults.standard
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
                case .none(let count) : value = ["none" : count as AnyObject]
                case .after(let count): value = ["after": count as AnyObject]
                case .never           : value = ["never": "" as AnyObject]
            }
            
            UserDefaults.standard.set(value, forKey: "ReviewStatusKey")
            UserDefaults.standard.synchronize()
        }
        
        // Review Statusを呼び出し
        static func readReviewStatus() -> ReviewStatus {
            if let status = UserDefaults.standard.object(forKey: "ReviewStatusKey") as? [String: AnyObject] {
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
        return Bundle.main.object(forInfoDictionaryKey: currenAppVersionKey) as! String
    }
    
    /// ReviewStatusをリセットする
    func resetStatus()  {
        reviewStatus = .none(count: 0)
    }
    
    /// 現在のVersionを保存する
    func setAppVersion()  {
        userDefault.set(currentAppVersion, forKey: appVersionKey)
        userDefault.synchronize()
    }
    
    /// UserDefaultのアプリVersionを比較する
    func compareAppVersion(_ version: String) -> Bool {
        return version == currentAppVersion ? true : false
    }
    
    /// レビューアラートを表示するかチェックする
    func checkReviewAlert(_ vc: UIViewController) {
        
        switch reviewStatus {
        case .none(var count) :
            count += 1
            reviewStatus = .none(count: count)
            if count >= firstAlertCount {
                showReviewAlert(vc)
            }
        case .after(var count):
            count += 1
            reviewStatus = .after(count: count)
            if count >= afterAlertCount {
                showReviewAlert(vc)
            }
        case .never:
            break
        }
    }
    
    /// レビューアラートを表示する
    func showReviewAlert(_ vc: UIViewController) {
        
        let alert = UIAlertController(title: "ReviewAlert",
                                      message: "message",
                                      preferredStyle: .alert)
        
        let reviewOKAction = UIAlertAction(title: "レビューする",
                                           style: .default,
                                           handler:
            { action in
                self.reviewStatus = .never
                // レビュー画面へ
                
                // Open iTunes Store
                let itunesReviewURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1094591345"
                let itunesURL = "itms-apps://itunes.apple.com/app/id1094591345"
                
                let app = UIApplication.shared
                if let url = URL(string:itunesReviewURL), app.canOpenURL(url) {
                    // iTunes Reviewページへ
                    app.openURL(url)
                } else if let url = URL(string:itunesURL), app.canOpenURL(url) {
                    // iTunes アプリページへ
                    app.openURL(url)
                }
        })
        
        // レビューあとで
        let reviewAfterAction = UIAlertAction(title: "後で",
                                              style: .default,
                                              handler:
            { action in
                self.reviewStatus = .after(count: 0)
        })
        
        // レビューNG
        let reviewNGAction = UIAlertAction(title: "レビューしない",
                                           style: .default,
                                           handler:
            { action in
                self.reviewStatus = .never
        })
        
        alert.addAction(reviewOKAction)
        alert.addAction(reviewAfterAction)
        alert.addAction(reviewNGAction)
        vc.present(alert, animated: true, completion: nil)
    }
}







