//
//  ForgotPasswordViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import RxSwift

class ForgotPasswordViewModel{
    private let authRepository = AuthRepository()
    
    func sendPasswordReset(email: String, completion: @escaping (String?) -> Void) {
            authRepository.sendPasswordReset(email: email) { result in
                switch result {
                case .success:
                    completion(nil) // Başarılı olduysa hata yok, nil döndür
                case .failure(let error):
                    completion(error.localizedDescription) // Hata mesajı döndür
                }
            }
        }
}
