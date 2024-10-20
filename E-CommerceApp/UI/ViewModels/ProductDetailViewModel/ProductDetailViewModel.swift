//
//  ProductDetailViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import Foundation

class ProductDetailViewModel{
    var productRepo = ProductRepository()
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
    
    func addProductToCart(name: String, productImage: String, productCategory: String, productPrice: Int, productBrand: String, productQty: Int, username: String, completion: @escaping (Bool) -> Void){
        productRepo.addProductToCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username){ success in
            if success{
                completion(true)
            } else{
                completion(false)
            }
        }
    }
}
