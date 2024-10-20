//
//  CartViewModel.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 14.10.2024.
//

import Foundation
import RxSwift

class CartViewModel{
    var productRepo = ProductRepository()
    var productListInCart = BehaviorSubject<[ProductCart]>(value: [ProductCart]())
    var username = UserDefaults.standard.string(forKey: "savedUsername") ?? "guest"
    var appliedDiscount: Int? = nil
    var discountedAmount: Int? = nil
    
    private let coupons: [Coupon] = [
        Coupon(code: "TURAL50", discountType: .percentage(50)),
        Coupon(code: "aydin", discountType: .percentage(70)),
        Coupon(code: "SEPETTE100", discountType: .fixedAmount(100))
    ]
    
    init(){
        getProductInCart()
        productListInCart = productRepo.productListInCart
    }
    
    
    func getProductInCart(){
        productRepo.getProductInCart(username: username)
    }
    
    func getImageURL(for imageName: String) -> String {
        return productRepo.getImageURL(for: imageName)
    }
    
    func deleteProductInCart(cartId: Int, completion: ((Bool) -> Void)? = nil) {
        productRepo.deleteProductInCart(cartId: cartId, username: username) { success in
            if success {
                self.productRepo.getProductInCart(username: self.username)
                completion?(true)  // completion varsa çağrılır, yoksa hiçbir şey yapılmaz
            } else {
                completion?(false)
            }
        }
    }
    
    func updateProductInCart(name: String, productImage: String, productCategory: String, productPrice: Int, productBrand: String, productQty: Int, process: Bool, completion: @escaping (Bool) -> Void){
        print("CardViewModel qty: \(productQty)")
        productRepo.updateProductInCart(name: name, productImage: productImage, productCategory: productCategory, productPrice: productPrice, productBrand: productBrand, productQty: productQty, username: username, process: process){ success in
            if success{
                completion(true)
            } else{
                completion(false)
            }
        }
    }
    
    // Kupon kodunu uygulayan fonksiyon
    func applyCoupon(code: String, to totalAmount: Int) -> (discountedAmount: Int, discount: Int)? {
        // Kupon kodu listeye eşleşiyorsa, indirim uygula
        if let coupon = coupons.first(where: { $0.code.lowercased() == code.lowercased() }) {
            return applyDiscount(on: totalAmount, with: coupon.discountType)
        } else {
            return (totalAmount, 0) // Kupon bulunamazsa indirim yapılmaz
        }
    }
    
    // İndirimi uygulayan fonksiyon
    private func applyDiscount(on totalAmount: Int, with discountType: DiscountType) -> (Int, Int) {
        switch discountType {
        case .fixedAmount(let amount):
            return (max(0, totalAmount - Int(amount)), Int(amount)) // Sabit indirim
        case .percentage(let percent):
            let discount = Double(totalAmount) * (percent / 100.0)  // Yüzdelik indirim
            return (max(0, totalAmount - Int(discount)), Int(discount)) // Yüzdelik indirim
        }
    }
    
    // Kupon tipini döndüren fonksiyon
    func getCouponType(for code: String) -> DiscountType? {
        return coupons.first(where: { $0.code.lowercased() == code.lowercased() })?.discountType
    }

}

