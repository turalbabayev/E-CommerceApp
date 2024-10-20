//
//  AccountViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var profilePhotoView: UIView!
    @IBOutlet weak var profileNameLogo: UILabel!
    @IBOutlet weak var username: UILabel!
    
    var viewModel = AccountViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = viewModel.getUserName()
        profileNameLogo.text = viewModel.getProfileLogo()
        profilePhotoView.layer.cornerRadius = profilePhotoView.frame.size.width / 2
        profilePhotoView.layer.masksToBounds = true
    }
    

    @IBAction func myOrdersTapped(_ sender: Any) {
        
    }
    @IBAction func logOutTapped(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "savedUsername")
        UserDefaults.standard.set(false, forKey: "isLoggedIn")

        navigateToLogin()
    }
    
    func navigateToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen // Tam ekran olarak göster
        present(loginViewController, animated: true, completion: nil)
    }
    
}
