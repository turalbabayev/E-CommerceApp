//
//  LoginViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import Foundation

class LoginViewModel {
    
    var onLoginSuccess: (() -> Void)?
    var onLoginError: ((String) -> Void)?

    // Kullanıcı giriş işlemi
    func loginUser(email: String, password: String) {
        AuthRepository.shared.loginUser(email: email, password: password) { [weak self] result in
            switch result {
            case .success(let authResult):
                // Firestore'dan kullanıcı verilerini çek
                FirestoreRepository().getUserData(uid: authResult.user.uid) { firestoreResult in
                    switch firestoreResult {
                    case .success(let userData):
                        // Kullanıcı adını al ve UserDefaults'a kaydet
                        let username = userData["username"] as? String ?? ""
                        UserDefaults.standard.set(username, forKey: "savedUsername")
                        UserDefaults.standard.set(email, forKey: "savedEmail")
                        self?.onLoginSuccess?()
                    case .failure(let error):
                        self?.onLoginError?(error.localizedDescription)
                    }
                }
            case .failure(let error):
                self?.onLoginError?(error.localizedDescription)
            }
        }
    }
}


