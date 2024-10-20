//
//  HomeViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 13.10.2024.
//

import Foundation
import RxSwift

class HomeViewModel{
    var productRepo = ProductRepository()
    private let firestoreRepository = FirestoreRepository()
    var productList = BehaviorSubject<[Products]>(value: [Products]())
    var categoryList = BehaviorSubject<[Category]>(value: [Category]())
    var ratingList = BehaviorSubject<[Rating]>(value: [Rating]())  // Rating bilgilerini tutan liste
    var username = UserDefaults.standard.string(forKey: "savedUsername")
    var descriptions: [Description] = []


    
    init() {
        loadProducts()
        loadCategory()
        productList = productRepo.productList
        categoryList = productRepo.categoryList
    }
    
    func loadProducts(){
        productRepo.loadProducts()
        //loadRatingsForProducts()  // Rating bilgilerini çek
    }
    
    func loadCategory(){
        productRepo.getCategoryList()
    }
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
    
    func filterProductsBySelectedCategories(selectedCategories: [String]){
        productRepo.filterProductsByCategory(selectedCategories: selectedCategories)
    }
    
    func filterProductsByPrice(maxValue: Int){
        productRepo.filterProductsByPrice(maxPrice: maxValue)
    }
    
    func filterProductsByCategoryAndPrice(selectedCategories: [String], maxPrice: Int) {
        productRepo.filterProductsByCategoryAndPrice(selectedCategories: selectedCategories, maxPrice: maxPrice)
    }
    
    func addProductToFavorites(product: Products, username: String, completion: @escaping (Bool) -> Void) {
        firestoreRepository.addProductToFavorites(product: product, username: username) { error in
            if let error = error {
                print("Favorilere eklenirken hata: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    
    func toggleFavorite(for product: Products, completion: @escaping (Bool) -> Void) {
        firestoreRepository.isProductInFavorites(product: product, username: username ?? "") { isFavorite in
            if isFavorite {
                // Favorilerden çıkar
                self.firestoreRepository.removeProductFromFavorites(product: product, username: self.username ?? "") { error in
                    if error == nil {
                        completion(false)  // Favoriden çıkarıldı
                    }
                }
            } else {
                // Favorilere ekle
                self.firestoreRepository.addProductToFavorites(product: product, username: self.username ?? "") { error in
                    if error == nil {
                        completion(true)  // Favorilere eklendi
                    }
                }
            }
        }
    }
    
    func isProductInFavorites(product: Products, completion: @escaping (Bool) -> Void) {
        firestoreRepository.isProductInFavorites(product: product, username: username ?? "guest", completion: completion)
    }
    
    func loadRatingsForProducts() {
        _ = productList.subscribe(onNext: { products in
            var ratings: [Rating] = []
            
            for product in products {
                // Firestore'dan rating değişikliklerini dinle
                self.firestoreRepository.listenForRatingChanges(productName: product.ad ?? "") { rating, reviewCount in
                    let ratingInfo = Rating(productName: product.ad ?? "", rating: rating, reviewCount: reviewCount)
                    if let index = ratings.firstIndex(where: { $0.productName == product.ad }) {
                        ratings[index] = ratingInfo
                    } else {
                        ratings.append(ratingInfo)
                    }
                    self.ratingList.onNext(ratings)
                }
            }
        })
    }
    
    // Ürünleri ve rating bilgilerini eşleştirip kullanma
    func combineProductAndRatings() -> Observable<[(Products, Rating?)]> {
        return Observable.combineLatest(productList, ratingList) { products, ratings in
            return products.map { product in
                let rating = ratings.first(where: { $0.productName == product.ad })
                return (product, rating)
            }
        }
    }
    
    func loadDescriptions() {
       self.descriptions = productRepo.fetchDescriptions()
   }

    
}
