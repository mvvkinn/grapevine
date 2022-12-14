//
//  FailViewController.swift
//  Grapevine
//
//  Created by 2017261069 윤재민 on 2022/12/07.
//

import UIKit
import AVFoundation

class FailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // 기능x
    @IBAction func closeBtn(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true)
    }
    

}
