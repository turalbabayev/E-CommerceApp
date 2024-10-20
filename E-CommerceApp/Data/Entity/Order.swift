//
//  Order.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 18.10.2024.
//

import Foundation

struct Order {
    let userName: String
    let products: [ProductCart]
    let orderDate: Date  // Sipariş tarihi
    //Sonradan eklenen
    let amount: [Amount]
}
