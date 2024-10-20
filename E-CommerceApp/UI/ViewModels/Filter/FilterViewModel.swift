//
//  FilterViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import Foundation
import RxSwift

class FilterViewModel{
    var productRepo = ProductRepository()
    var productList = BehaviorSubject<[Products]>(value: [Products]())
    var categoryList = BehaviorSubject<[Category]>(value: [Category]())

    
    init() {
        productList = productRepo.productList
        categoryList = productRepo.categoryList
        loadCategory()
    }
    
    func filterProductsByCategory(selectedCategories: [String]){
        productRepo.filterProductsByCategory(selectedCategories: selectedCategories)
    }
    
    func loadCategory(){
        productRepo.getCategoryList()
    }
}
