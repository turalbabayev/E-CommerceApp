//
//  FavoritesCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 17.10.2024.
//

import UIKit

class FavoritesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var deleteBackgroundView: UIView!
    @IBOutlet weak var productRate: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productPriceBackgroundView: UIView!
    @IBOutlet weak var productImage: UIImageView!
    
    var deleteButtonTapped: (() -> Void)?
    
    func setup(_ product: Products){
        deleteBackgroundView.backgroundColor = .clear
        productPriceBackgroundView.backgroundColor = .clear
        deleteBackgroundView.cornerRadius = 12
        productPriceBackgroundView.cornerRadius = 12
        productTitle.text = product.ad!
        productBrand.text = product.marka!
        productPrice.text = String("₺\(product.fiyat!)")
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteButtonTapped?()
    }
    
}
