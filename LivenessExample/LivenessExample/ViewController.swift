//
//  ViewController.swift
//  LivenessExample
//
//  Created by DOKU IT on 28/04/22.
//

import UIKit
import LivenessCamera

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionButton(_ sender: Any) {
        let vc = LivenessCameraView(rootVC: self)
        vc.loadLivenessCamera()
    }
    
}

