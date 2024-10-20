//
//  PaymentSuccessViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import UIKit
import Lottie

class PaymentSuccessViewController: UIViewController {
    @IBOutlet weak var animationView: LottieAnimationView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.animationView.contentMode = .scaleAspectFit
        self.animationView.loopMode = .loop
        self.animationView.animationSpeed = 0.5
        self.animationView.play()

    }

    @IBAction func detailOrderTapped(_ sender: Any) {
    }
    
    @IBAction func backToHomeTapped(_ sender: Any) {
        if let viewController = self.navigationController?.viewControllers.first {
            self.navigationController?.popToViewController(viewController, animated: true)
        }
    }
    
}
