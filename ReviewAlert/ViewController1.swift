//
//  ViewController1.swift
//  ReviewAlert
//
//  Created by Kentarou on 2016/09/01.
//  Copyright © 2016年 Kentarou. All rights reserved.
//

import UIKit

class ViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // ReviewAlert Check
        ReviewAlert.sharedInstance.checkReviewAlert(self)
    }
}
