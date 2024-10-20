//
//  SignUpViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import RxSwift
import Foundation

class SignUpViewModel{
    
    var onRegisterSuccess: (() -> Void)?
    var onRegisterError: ((String) -> Void)?
    
    // Kullanıcı kayıt işlemi
    func registerUser(email: String, password: String, username: String) {
        AuthRepository.shared.registerUser(email: email, password: password, username: username) { [weak self] result in
            switch result {
            case .success(let authResult):
                // Firestore'a kullanıcı verilerini kaydetme işlemi
                FirestoreRepository().saveUserData(uid: authResult.user.uid, email: email, username: username) { error in
                    if let error = error {
                        self?.onRegisterError?(error.localizedDescription)
                    } else {
                        // Kullanıcı adı kaydediliyor
                        UserDefaults.standard.set(username, forKey: "savedUsername")
                        UserDefaults.standard.set(email, forKey: "savedEmail")
                        self?.onRegisterSuccess?()
                    }
                }
            case .failure(let error):
                self?.onRegisterError?(error.localizedDescription)
            }
        }
    }
}
