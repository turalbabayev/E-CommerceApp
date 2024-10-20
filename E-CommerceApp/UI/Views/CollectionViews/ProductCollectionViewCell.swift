//
//  ProductCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 13.10.2024.
//

import UIKit


class ProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productRating: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productBrand: UILabel!

    
    var favoriteButtonTapped: (() -> Void)?
    var isFavorite = false
    var removeFavoriteButtonTapped: (() -> Void)? 


    
    func setup(_ product: Products, isFavorite: Bool){
        productPrice.text =  String("₺\(product.fiyat!)")
        productTitle.text = product.ad
        productBrand.text = product.marka
        
        
        // Favori durumunu kontrol ediyoruz
        self.isFavorite = isFavorite
        updateFavoriteButton()
        
    }
    
    func updateFavoriteButton() {
        // Eğer favorilerdeyse `heart.fill`, değilse `heart`
        let buttonImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favButton.setImage(buttonImage, for: .normal)
    }
    
    @IBAction func favButtonTapped(_ sender: Any) {
        if isFavorite {
            // Favoriden çıkar
            removeFavoriteButtonTapped?()
        } else {
            // Favorilere ekle
            favoriteButtonTapped?()
        }
        // Favori durumunu güncelle
        isFavorite.toggle()
        updateFavoriteButton()
    }
    
}
