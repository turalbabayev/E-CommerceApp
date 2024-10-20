//
//  ForgetPasswordViewController.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import UIKit
import RxSwift
import RxCocoa

class ForgotPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let viewModel = ForgotPasswordViewModel()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        emailTextField.setLeftIcon(UIImage(systemName: "envelope")!)
        emailTextField.setupBorderStyle()
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        activityIndicator.style = .large
        activityIndicator.color = .gray

        
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        navigateToLogin()
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Lütfen geçerli bir e-posta adresi girin.")
            return
        }
        
        activityIndicator.startAnimating()


        viewModel.sendPasswordReset(email: email) { [weak self] errorMessage in
            self?.activityIndicator.stopAnimating()

            if let errorMessage = errorMessage {
                self?.showAlert(message: errorMessage) // Hata mesajı göster
            } else {
                self?.showAlert(message: "Şifre yenileme bağlantısı gönderildi.")
            }
        }
    }
    
    
    
    func showLoadingIndicator() {
        let alert = UIAlertController(title: nil, message: "Lütfen bekleyin...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        
        alert.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor)
        ])
        
        present(alert, animated: true, completion: nil)
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func navigateToLogin() {
        let loginViewController = storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginViewController.modalPresentationStyle = .fullScreen // Tam ekran olarak göster
        present(loginViewController, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate{
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
