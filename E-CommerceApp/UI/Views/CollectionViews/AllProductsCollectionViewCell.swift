//
//  AllProductsCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit

class AllProductsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productRate: UILabel!
    @IBOutlet weak var favButtonView: UIView!
    
    
    
    func setup(_ product: Products){
        productImage.image = UIImage(named: product.resim ?? "")
        productPrice.text =  String("₺\(product.fiyat!)")
        productTitle.text = product.ad
        productBrand.text = product.marka
        
    }
    
    @IBAction func favButtonTapped(_ sender: UIButton) {
        
    }
    
    
}
