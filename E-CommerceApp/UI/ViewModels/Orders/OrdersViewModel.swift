//
//  OrdersViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import Foundation


class OrdersViewModel{
    let repository = FirestoreRepository()
    let productRepository = ProductRepository()

    // Kullanıcı adına göre siparişleri getirme
    func getOrders(for userName: String, completion: @escaping ([Order]?) -> Void) {
        repository.getOrders(for: userName) { orders in
            completion(orders)
        }
    }
    
    func getImageURL(for imageName: String) -> String {
        return productRepository.getImageURL(for: imageName)
    }
}
