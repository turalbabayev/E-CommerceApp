//
//  SearchViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import Foundation
import RxSwift

class SearchViewModel{
    private let repository = FirestoreRepository()
    var previousSearchList = BehaviorSubject<[String]>(value: [String]())
    var productList = BehaviorSubject<[Products]>(value: [Products]())
    var username = UserDefaults.standard.string(forKey: "savedUsername")
    private let productRepo = ProductRepository()

    
    init(){
        loadSearchHistory()
        loadProducts()
        previousSearchList = repository.previousSearchList
        productList = productRepo.productList
    }
    
    func loadSearchHistory(){
        repository.getSearchHistory(username: username!)
    }
    
    func addSearchTerm(searchTerm: String){
        repository.saveSearchHistory(username: username!, searchTerm: searchTerm)
    }
    
    func deleteSearchTerm(searchTerm: String){
        repository.deleteSearchTerm(username: username!, searchTerm: searchTerm)
        loadSearchHistory()
    }
    
    func clearSearchHistory(){
        repository.clearSearchHistory(username: username!)
        loadSearchHistory()
    }
    
    func getImageURL(for imageName: String) -> String{
        productRepo.getImageURL(for: imageName)
    }
    
    func loadProducts(){
        productRepo.loadProducts()
    }
    
    func searchProductsLocally(searchTerm: String){
        productRepo.searchProductsLocally(searchTerm: searchTerm)
    }
}


