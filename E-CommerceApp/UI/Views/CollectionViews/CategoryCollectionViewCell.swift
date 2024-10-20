//
//  CategoryCollectionViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 13.10.2024.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryContentView: UIView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryImageView: UIImageView!
    
    
    func setup(_ category: Category){
        categoryImageView.image = UIImage(named: category.image)
        categoryTitle.text = category.title
        categoryContentView.cornerRadius = 12
        categoryImageView.cornerRadius = 12
    }
}
