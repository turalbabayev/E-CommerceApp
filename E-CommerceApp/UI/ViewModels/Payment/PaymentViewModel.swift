//
//  PaymentViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import Foundation

class PaymentViewModel{
    let repository = FirestoreRepository()

    // Firestore'a sipariş kaydetme fonksiyonu
    func saveOrderToFirestore(products: [ProductCart], userName: String, amount: Amount, completion: @escaping (Bool) -> Void) {
        repository.saveOrder(userName: userName, products: products, amount: amount) { success in
            completion(success)
        }
    }
}
