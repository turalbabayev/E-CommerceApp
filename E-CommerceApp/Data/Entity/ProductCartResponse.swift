//
//  ProductCartResponse.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import Foundation


class ProductCartResponse: Codable{
    var urunler_sepeti: [ProductCart]?
    var success: Int?
}
