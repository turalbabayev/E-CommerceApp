//
//  AllProductsViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import Foundation
import RxSwift

class AllProductsViewModel{
    var productRepo = ProductRepository()
    var productList = BehaviorSubject<[Products]>(value: [Products]())
    
    init() {
        loadProducts()
        productList = productRepo.productList
    }
    
    func loadProducts(){
        productRepo.loadProducts()
    }
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
}
