//
//  AllCategoryViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import Foundation
import RxSwift


class AllCategoryViewModel{
    var productRepo = ProductRepository()
    var categoryList = BehaviorSubject<[Category]>(value: [Category]())
    
    init() {
        getCategoryList()
        categoryList = productRepo.categoryList
    }
    
    func getCategoryList(){
        productRepo.getCategoryList()
    }
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
}
