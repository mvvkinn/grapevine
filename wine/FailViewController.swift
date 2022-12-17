//
//  FailViewController.swift
//  Grapevine
//
//  Created by 2017261069 윤재민 on 2022/12/07.
//

import UIKit

class FailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func exit(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
}
