//
//  OrderDetailViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 20.10.2024.
//

import Foundation

class OrderDetailViewModel{
    private let productRepo = ProductRepository()
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
}
