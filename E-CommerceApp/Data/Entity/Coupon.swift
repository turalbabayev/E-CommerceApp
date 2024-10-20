//
//  Coupon.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import Foundation

struct Coupon {
    let code: String
    let discountType: DiscountType
}

enum DiscountType {
    case fixedAmount(Double)   // Sabit miktarda indirim
    case percentage(Double)    // Yüzdelik indirim
}


