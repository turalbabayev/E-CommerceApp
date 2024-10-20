//
//  CategoryInFilterCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit

class CategoryInFilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var backgroundViewCell: UIView!
    @IBOutlet weak var categoryName: UILabel!
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Arka planın yuvarlanmasını sağlamak
        backgroundViewCell.layer.cornerRadius = 10
    }
}
