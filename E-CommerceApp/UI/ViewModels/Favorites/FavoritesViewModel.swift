//
//  FavoritesViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import Foundation
import RxSwift

class FavoritesViewModel{
    var favoritedProducts = BehaviorSubject<[Products]>(value: [Products]())
    private let firestoreRepository = FirestoreRepository()
    private let productRepo = ProductRepository()
    var username = UserDefaults.standard.string(forKey: "savedUsername")
    
    init(){
        //getFavorites()
        //favoritedProducts = firestoreRepo.favoritedProducts
    }
    
    func loadFavorites(completion: @escaping ([Products]) -> Void) {
        let username = UserDefaults.standard.string(forKey: "savedUsername") ?? ""
        firestoreRepository.getFavoriteProducts(username: username) { favorites in
            completion(favorites)
        }
    }
    
    func removeProductFromFavorites(product: Products, completion: @escaping (Bool) -> Void) {
        let username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
        firestoreRepository.removeProductFromFavorites(product: product, username: username) { error in
            if let error = error {
                print("Favorilerden çıkarırken hata: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
    
}
