//
//  SignUpViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

class SignUpViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var googleSignButton: UIButton!
    @IBOutlet weak var facebookSignButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    
    let viewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordAgainTextField.delegate = self
        activityIndicator.isHidden = true

        
        
        
        
        
        
        
        // Varsaylan Duzenlemeler
        usernameTextField.setLeftIcon(UIImage(systemName: "person")!)
        usernameTextField.setupBorderStyle()
        emailTextField.setLeftIcon(UIImage(systemName: "envelope")!)
        emailTextField.setupBorderStyle()
        passwordTextField.setLeftIcon(UIImage(systemName: "lock")!)
        passwordTextField.setRightIcon(UIImage(systemName: "eye.slash")!, target: self, action: #selector(togglePasswordVisibility))
        passwordTextField.setupBorderStyle()
        passwordAgainTextField.setLeftIcon(UIImage(systemName: "lock")!)
        passwordAgainTextField.setRightIcon(UIImage(systemName: "eye.slash")!, target: self, action: #selector(togglePasswordAgainVisibility))
        passwordAgainTextField.setupBorderStyle()
        
        setupBindings()
        activityIndicator.isHidden = true
        signUpButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        
    }
    
    @objc func registerTapped() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let passwordAgain = passwordAgainTextField.text, password == passwordAgain else {
            showError("Lütfen tüm alanları doğru şekilde doldurun.")
            return
        }
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        viewModel.registerUser(email: email, password: password, username: username)
    }
    
    private func setupBindings() {
        viewModel.onRegisterSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.navigateToLogin()
            }
        }

        viewModel.onRegisterError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.showError(errorMessage)
            }
        }
    }
    
    
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func googleSignTapped(_ sender: Any) {
    }
    @IBAction func facebookSignTapped(_ sender: Any) {
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        navigateToLogin()
    }
    
    func navigateToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen // Tam ekran olarak göster
        present(loginViewController, animated: true, completion: nil)
    }

   func showError(_ message: String) {
       let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
       alert.addAction(UIAlertAction(title: "Tamam", style: .default))
       present(alert, animated: true)
   }

    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle() // Şifre alanının görünürlüğünü değiştir
        
        // Sağdaki ikonu güncelle
        if let rightIconView = passwordTextField.rightView?.subviews.first as? UIImageView {
            let iconName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            rightIconView.image = UIImage(systemName: iconName)
        }
    }
    
    @objc func togglePasswordAgainVisibility() {
        passwordAgainTextField.isSecureTextEntry.toggle() // Şifre alanının görünürlüğünü değiştir
        
        // Sağdaki ikonu güncelle
        if let rightIconView = passwordAgainTextField.rightView?.subviews.first as? UIImageView {
            let iconName = passwordAgainTextField.isSecureTextEntry ? "eye.slash" : "eye"
            rightIconView.image = UIImage(systemName: iconName)
        }
    }
    
}

extension SignUpViewController: UITextFieldDelegate{
    // Yazı yazılmaya başlandığında
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.updateBorder(isEditing: true)
    }
    
    // Yazı yazma bittiğinde
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            // Eğer text varsa turuncu border kalsın
            textField.layer.borderWidth = 1.5
            textField.layer.borderColor = UIColor.orange.cgColor
        } else {
            // Eğer text yoksa border'ı kaldır
            textField.updateBorder(isEditing: false)
        }
    }
}
