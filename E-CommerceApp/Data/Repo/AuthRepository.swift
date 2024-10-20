//
//  AuthRepository.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 12.10.2024.
//

import FirebaseAuth
import RxSwift
import FirebaseFirestore


class AuthRepository{
    
    static let shared = AuthRepository()
    let firebaseRepository = FirestoreRepository()
    let db = Firestore.firestore()
    
    // Firebase Auth ile kayıt işlemi
    func registerUser(email: String, password: String, username: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                // Firestore'a kullanıcı adı ve diğer bilgileri kaydet
                self.firebaseRepository.saveUserData(uid: authResult.user.uid, email: email, username: username) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(authResult))
                    }
                }
            }
        }
    }

    // Firebase Auth ile giriş işlemi
    func loginUser(email: String, password: String, completion: @escaping (Result<AuthDataResult, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else if let authResult = authResult {
                completion(.success(authResult))
            }
        }
    }

    
    func sendPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    
    
    
}
