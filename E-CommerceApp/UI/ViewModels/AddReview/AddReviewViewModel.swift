//
//  AddReviewViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import Foundation

class AddReviewViewModel{
    private let productRepo = ProductRepository()
    var product: ProductCart?  // Ürün bilgileri
    private let repository = FirestoreRepository()


    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
    
    // Yorum ve ratingi Firestore'a kaydetme
    func submitReview(reviewText: String, rating: Double, completion: @escaping (Bool) -> Void) {
        guard let product = product else {
            completion(false)
            return
        }
        
        // Firestore'a gönderilecek veriler
        repository.saveReview(productName: product.ad ?? "", reviewText: reviewText, rating: rating, completion: completion)
    }
    
    
}
