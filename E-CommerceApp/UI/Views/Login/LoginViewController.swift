//
//  LoginViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import RxSwift
import RxCocoa
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var googleSignButton: UIButton!
    @IBOutlet weak var facebookSignButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // Spinner ekliyoruz

    
    let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        activityIndicator.isHidden = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        

        emailTextField.setLeftIcon(UIImage(systemName: "envelope")!)
        emailTextField.setupBorderStyle()

        passwordTextField.setLeftIcon(UIImage(systemName: "lock")!)
        passwordTextField.setRightIcon(UIImage(systemName: "eye.slash")!, target: self, action: #selector(togglePasswordVisibility))
        passwordTextField.setupBorderStyle()
        
    }
    
    @objc func loginTapped() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showError("Lütfen tüm alanları doldurun.")
            return
        }

        activityIndicator.isHidden = false
        activityIndicator.startAnimating()

        viewModel.loginUser(email: email, password: password)
    }
    
    private func setupBindings() {
        viewModel.onLoginSuccess = { [weak self] in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                UserDefaults.standard.set(true, forKey: "isLoggedIn")
                self?.navigateToHome()
            }
        }

        viewModel.onLoginError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.activityIndicator.isHidden = true
                self?.showError(errorMessage)
            }
        }
    }

    @IBAction func forgatPasswordTapped(_ sender: UIButton) {
        let forgotPasswordViewController = storyboard?.instantiateViewController(identifier: "forgotPasswordViewController") as! ForgotPasswordViewController
        forgotPasswordViewController.modalPresentationStyle = .fullScreen
        present(forgotPasswordViewController, animated: true, completion: nil)
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showError("Lütfen tüm alanları doldurun.")
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        viewModel.loginUser(email: email, password: password)
    }
    
    @IBAction func googleSignTapped(_ sender: Any) {
        print("google giris tiklandi")
    }
    
    @IBAction func facebookSignTapped(_ sender: Any) {
        print("facebook giris tiklandi")
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let signUpViewController = storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        signUpViewController.modalPresentationStyle = .fullScreen
        present(signUpViewController, animated: true, completion: nil)
    }
    
    
    
    
    func navigateToHome() {
        let homeNavigationController = storyboard?.instantiateViewController(identifier: "homeNavigationController") as! UINavigationController
        homeNavigationController.modalPresentationStyle = .fullScreen // Tam ekran olarak göster
        present(homeNavigationController, animated: true, completion: nil)
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Hata", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
    
    @objc func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle() // Şifre alanının görünürlüğünü değiştir
        
        if let rightIconView = passwordTextField.rightView?.subviews.first as? UIImageView {
            let iconName = passwordTextField.isSecureTextEntry ? "eye.slash" : "eye"
            rightIconView.image = UIImage(systemName: iconName)
        }
    }
    
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.updateBorder(isEditing: true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            textField.layer.borderWidth = 1.5
            textField.layer.borderColor = UIColor.orange.cgColor
        } else {
            textField.updateBorder(isEditing: false)
        }
    }
}
