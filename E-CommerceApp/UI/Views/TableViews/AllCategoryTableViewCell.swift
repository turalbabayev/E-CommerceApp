//
//  AllCategoryTableViewCell.swift
//  E-CommerceApp
//
//  Created by Tural Babayev on 16.10.2024.
//

import UIKit

class AllCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    @IBOutlet weak var productCount: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    // Hücre seçildiğinde border ve border rengi ekle
    func setSelectedState(isSelected: Bool) {
        
    }

}
